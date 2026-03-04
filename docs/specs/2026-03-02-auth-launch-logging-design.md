# Auth & Launch Logging — Design

**Date:** 2026-03-02
**Status:** Draft
**Related:** `2026-03-02-referer-validation-research.md`

---

## Problem

When investigating authentication and launch issues (e.g., referer validation
failures), production logs provide almost no visibility. Devise strategy
failures are silent, API auth errors are swallowed, and there are no ALB access
logs to fall back on.

The referer-validation research (see `docs/specs/referer-validation-research.md`)
identified this as a critical blind spot: when a bearer token fails validation
for any reason, nothing is logged.

## Goals

- Log authentication failures with enough context to diagnose issues (client
  name, referer, token type, request path)
- Record which auth strategy succeeded on every request for audit trail
- Enable ALB access logs for HTTP-level visibility independent of Rails

## Non-Goals

- Structured/JSON logging (keeping plain text for now)
- Launch event logging (existing database records cover this)
- Rollbar re-enablement (separate decision)
- Broad operational logging beyond auth paths

## Design

### Change 1: Auth Strategy Tagging via `request.env`

On successful authentication, each Devise strategy sets
`request.env['portal.auth_strategy']` so downstream code (and the request log)
can see which strategy authenticated the request.

**`rails/lib/bearer_token_authenticatable.rb`** — on `success!`:
```ruby
request.env['portal.auth_strategy'] = 'bearer_token'
request.env['portal.auth_client'] = grant.client.name
```

**`rails/lib/jwt_bearer_token_authenticatable.rb`** — on `success!`:
```ruby
request.env['portal.auth_strategy'] = 'jwt_bearer_token'
```

**`rails/app/controllers/api/api_controller.rb`** — in `check_for_auth_token`:
```ruby
# After successful JWT decode:
request.env['portal.auth_strategy'] = 'api_jwt'

# After successful AccessGrant lookup:
request.env['portal.auth_strategy'] = 'api_access_grant'
request.env['portal.auth_client'] = grant.client&.name

# After session fallback:
request.env['portal.auth_strategy'] = 'api_session'
```

### Change 2: `append_info_to_payload` in ApplicationController

Override `append_info_to_payload` to include auth info in every request's
completion log line.

**`rails/app/controllers/application_controller.rb`**:
```ruby
def append_info_to_payload(payload)
  super
  payload[:user_id] = current_user&.id
  payload[:auth_strategy] = request.env['portal.auth_strategy']
  payload[:auth_client] = request.env['portal.auth_client']
end
```

Note: `current_user` can be nil for unauthenticated requests. The `&.` safe
navigation handles this — `user_id` will be nil in the log.

**`rails/config/initializers/auth_log_subscriber.rb`** — custom log subscriber
to append the extra payload fields to the "Completed 200 OK in 45ms" line:
```ruby
module AuthLogSubscriber
  def process_action(event)
    super
    payload = event.payload
    additions = []
    additions << "user=#{payload[:user_id]}" if payload[:user_id]
    additions << "auth=#{payload[:auth_strategy]}" if payload[:auth_strategy]
    additions << "client=#{payload[:auth_client]}" if payload[:auth_client]
    info("  Auth: #{additions.join(' ')}") if additions.any?
  end
end
```

### Change 3: Targeted Warn Logs at Failure Points

These log at `warn` level so they always appear in production (log level `:info`).

**`rails/lib/bearer_token_authenticatable.rb`** — in `token_valid?`:
```ruby
def token_valid?
  token = token_value
  return false unless token
  grant = AccessGrant.find_by_access_token(token)
  return false unless grant && grant.client
  unless grant.client.valid_from_referer?(referer)
    Rails.logger.warn(
      "BearerToken: referer rejected" \
      " - client=#{grant.client.name}" \
      ", referer=#{referer}" \
      ", matchers=#{grant.client.domain_matchers}"
    )
    return false
  end
  return true
end
```

Only the referer rejection case is logged here. Missing grants are not logged
because JWT tokens handled by other strategies would trigger false positives.

**`rails/lib/jwt_bearer_token_authenticatable.rb`** — in `authenticate!` and
`decode_token`:
```ruby
def authenticate!
  decoded_token = decode_token
  unless decoded_token && decoded_token[:data].has_key?("uid")
    Rails.logger.warn("JwtBearerToken: token decode failed or missing uid")
    return fail!
  end
  user = User.find_by_id(decoded_token[:data]["uid"])
  unless user
    Rails.logger.warn(
      "JwtBearerToken: user not found for uid=#{decoded_token[:data]['uid']}"
    )
    return fail!
  end
  request.env['portal.auth_strategy'] = 'jwt_bearer_token'
  success!(user)
end

def decode_token
  return nil unless has_jwt_bearer_token?()
  strategy, token = get_strategy_and_token()
  SignedJwt::decode_portal_token(token)
rescue => e
  Rails.logger.warn("JwtBearerToken: decode error - #{e.message}")
  nil
end
```

**`rails/app/controllers/api/api_controller.rb`** — in `auth_not_anonymous`:
```ruby
def auth_not_anonymous(params)
  begin
    user, role = check_for_auth_token(params)
  rescue StandardError => e
    Rails.logger.warn("API auth failed: #{e.message}, path=#{request.path}")
    return {error: e.message}
  end
  # ...
end
```

**`rails/lib/custom_failure.rb`** — in `respond`:
```ruby
def respond
  message = warden.message || warden_options[:message]
  Rails.logger.warn(
    "Devise auth failure: message=#{message}, path=#{request.path}"
  )
  # ... existing logic
end
```

### Change 4: ALB Access Logs (CloudFormation)

Enable ALB access logs to capture HTTP-level request data (client IP, status
code, request path, response time, TLS version) independent of Rails.

**`configs/cloudformation/stack_template.yml`**:

1. Add parameter:
```yaml
EnableALBAccessLogs:
  Type: String
  Default: "false"
  AllowedValues: ["true", "false"]
  Description: Enable ALB access logs to S3
```

2. Add condition:
```yaml
EnableALBAccessLogsCond:
  !Equals [!Ref EnableALBAccessLogs, "true"]
```

3. Add S3 bucket resource (conditional):
```yaml
ALBAccessLogsBucket:
  Type: AWS::S3::Bucket
  Condition: EnableALBAccessLogsCond
  Properties:
    LifecycleConfiguration:
      Rules:
        - ExpirationInDays: 30
          Status: Enabled
    BucketPolicy: # Allow ELB account to write logs
```

4. Add bucket policy granting the ELB service account write access (AWS account
   `127311923021` for us-east-1).

5. Pass access log configuration to the `LoadBalancerStack` nested template, or
   add `LoadBalancerAttributes` directly if the nested template supports it:
```yaml
LoadBalancerAttributes:
  - Key: access_logs.s3.enabled
    Value: !If [EnableALBAccessLogsCond, "true", "false"]
  - Key: access_logs.s3.bucket
    Value: !If [EnableALBAccessLogsCond, !Ref ALBAccessLogsBucket, ""]
  - Key: access_logs.s3.prefix
    Value: portal
```

## Files Modified

| File | Change |
|------|--------|
| `rails/lib/bearer_token_authenticatable.rb` | Referer rejection warn log + auth strategy env tag |
| `rails/lib/jwt_bearer_token_authenticatable.rb` | Decode/user-not-found warn logs + auth strategy env tag |
| `rails/app/controllers/api/api_controller.rb` | Auth failure warn log + auth strategy env tags |
| `rails/lib/custom_failure.rb` | Devise failure warn log |
| `rails/app/controllers/application_controller.rb` | `append_info_to_payload` override |
| `rails/config/initializers/auth_log_subscriber.rb` | New file: log subscriber for auth fields |
| `configs/cloudformation/stack_template.yml` | ALB access logs parameter, condition, S3 bucket |

## Testing

- Verify warn logs appear when bearer token auth fails due to referer mismatch
  (use a test with a mismatched referer)
- Verify JWT decode failure is logged
- Verify `append_info_to_payload` adds auth fields to request log in
  development
- Verify ALB access logs parameter can be toggled without breaking the stack
  (test with `false` default)
