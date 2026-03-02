# Referer Validation Impact on Controller Migration — Research

**Date:** 2026-02-28
**Status:** Complete — referer validation is not a blocker for Step 1
**Related:** `../portal-authentication-unification-design.md` Section 5, Section 6 Step 1, Discussion Question 4

---

## Problem Statement

Section 6 Step 1 of the unification design calls for migrating four controllers from `check_for_auth_token` to `current_user`. This changes how AccessGrant bearer tokens are authenticated:

**Today:** A request with `Authorization: Bearer <hex-token>` hits two auth paths:
1. Devise `BearerTokenAuthenticatable` runs first — looks up the grant, checks `grant.client` exists, validates `grant.client.valid_from_referer?(referer)`. If the referer check **fails**, the strategy returns `fail(:invalid_token)` and `current_user` is not set.
2. The controller calls `check_for_auth_token`, which independently looks up the grant **without checking the client or referer** — authentication succeeds anyway.

**After Step 1:** Controllers use `current_user` instead of `check_for_auth_token`. If the Devise referer check fails, `current_user` is nil, and the request fails.

Any request that currently works *despite* failing the Devise referer check would break after Step 1.

### When the referer check passes (safe)

From `rails/app/models/client.rb:12-18`:
- `domain_matchers` is blank/nil → `enforce_referrer?` returns false → always passes
- `domain_matchers` is set AND referer matches the regex → passes

### When the referer check fails (risk)

- `domain_matchers` is set AND referer is **missing** (e.g., server-to-server calls)
- `domain_matchers` is set AND referer **doesn't match** (misconfigured `domain_matchers`)

### Only AccessGrant bearer tokens are affected

JWTs (`Bearer <token-with-dots>`) are unaffected: the Devise bearer strategy calls `AccessGrant.find_by_access_token(jwt_string)` which returns nil (JWTs are not in the `access_grants` table), so the strategy exits early at `bearer_token_authenticatable.rb:24` before reaching the referer check.

The Devise `token_authenticatable` strategy (query parameter `?access_token=...`) is also unaffected — it has no referer check.

---

## Method

### Approach 1: Database analysis — which Clients enforce referer checks?

Query production Client records to see which have `domain_matchers` set. If the Clients used by callers of these endpoints have blank `domain_matchers`, the referer check is a no-op and Step 1 is safe for those callers.

**Active Record query (for rails console):**

```ruby
Client.all.order(:name).each do |c|
  enforces = c.domain_matchers.present? && c.domain_matchers.strip.present?
  puts "#{c.id.to_s.ljust(4)} #{(enforces ? 'ENFORCES' : 'no check').ljust(10)} #{c.name.ljust(40)} domain_matchers: #{c.domain_matchers.inspect}"
end; nil
```

**Follow-up — cross-reference with active grants on affected endpoints:**

The ideal cross-reference would be: which Clients back the AccessGrants actually used to call these four endpoints? Unfortunately, the AccessGrant table doesn't record which endpoint it was used on, so this cross-reference requires either log analysis or source code analysis of callers (see Approach 3).

A less precise but still useful query — which Clients have active (unexpired) grants?

```ruby
Client.joins(:access_grants)
  .where("access_grants.access_token_expires_at > ?", Time.now)
  .distinct
  .each do |c|
    enforces = c.domain_matchers.present? && c.domain_matchers.strip.present?
    grant_count = c.access_grants.where("access_token_expires_at > ?", Time.now).count
    puts "#{c.id.to_s.ljust(4)} #{(enforces ? 'ENFORCES' : 'no check').ljust(10)} #{c.name.ljust(40)} active_grants: #{grant_count} domain_matchers: #{c.domain_matchers.inspect}"
  end; nil
```

### Approach 2: Log analysis — authentication failure detection

Rails production logs (`learn-ecs-production`) do not capture Authorization headers or Referer headers. ALB access logs are not enabled on the Portal load balancers. This limits what can be determined from existing logs.

**What IS logged:** Rails logs request paths, methods, and response codes. The `check_for_auth_token` method raises `StandardError` on auth failures, which controllers catch and return as 400/401 responses.

**What is NOT logged:** The Devise bearer strategy fails silently — when `BearerTokenAuthenticatable` returns `fail(:invalid_token)` (including due to referer mismatch), nothing is written to the Rails log at `:info` level. The `CustomFailure` class (`lib/custom_failure.rb`) processes the failure but does not log it either.

**Possible approach — add temporary logging:**

Add logging to the Devise bearer strategy to capture referer check failures:

```ruby
# In bearer_token_authenticatable.rb, token_valid? method:
def token_valid?
  token = token_value
  return false unless token
  grant = AccessGrant.find_by_access_token(token)
  return false unless grant && grant.client
  unless grant.client.valid_from_referer?(referer)
    Rails.logger.info("BearerToken referer check failed: client=#{grant.client.name} referer=#{referer.inspect} domain_matchers=#{grant.client.domain_matchers.inspect} path=#{request.path}")
    return false
  end
  return true
end
```

Deploy this logging, wait a representative period (1-2 weeks covering school days), then analyze the logs. If there are zero referer failures, Step 1 is safe. If there are failures, the logs tell us exactly which clients and referer domains are affected.

**Note:** This logging would fire for ALL requests with Bearer tokens across the entire app, not just the four controllers being migrated. This is actually useful — it tells us whether the referer check is causing silent failures anywhere. The only cost is log volume, which should be modest since each log line is a single INFO entry.

### Approach 3: External source code analysis — who calls these endpoints?

GitHub org search (`concord-consortium`) for the four endpoint paths:

| Endpoint | External consumers | Auth mechanism |
|---|---|---|
| `api/v1/bookmarks` | **None** — Portal-internal React components only (`bookmarks/edit.tsx`) | Session cookies (no `Authorization` header in the React component) |
| `api/v1/teacher_classes` | **None** — Portal-internal React components only (`manage-classes.tsx`) | Session cookies (no `Authorization` header in the React component) |
| `api/v1/external_activities` | **LARA** (`lib/concord/auth_portal.rb`) — publishing/updating activities | See "LARA publishing auth" below |
| `api/v1/offerings` (only `create_for_external_activity` uses `check_for_auth_token`) | **CLUE** (`src/lib/portal-api.ts`) — CLUE Standalone creating offerings | Portal JWT via `Bearer/JWT` header — see "CLUE Standalone auth" below |

Other repos reference `api/v1/offerings` (activity-player, portal-report, report-service, teaching-teamwork), but they call `show`/`index`/`update` which already use `current_user` + Pundit — not `check_for_auth_token`.

#### CLUE Standalone auth chain (verified via source)

CLUE's `createPortalOffering()` function (`src/lib/portal-api.ts`) sends `Authorization: Bearer/JWT <portalJWT>`. The full chain:

1. **OAuth2 implicit grant** (`src/utilities/auth-utils.ts`) — user redirected to Portal, gets back `#access_token=...` (an AccessGrant token)
2. **Immediate JWT exchange** (`src/models/stores/portal.ts`, `requestPortalJWT()`) — sends `GET /api/v1/jwt/portal` with `Authorization: Bearer <accessGrantToken>`, receives a signed Portal JWT
3. **All subsequent API calls use the Portal JWT** — including `POST /api/v1/offerings/create_for_external_activity` with `Authorization: Bearer/JWT <portalJWT>`

The raw AccessGrant token is never sent to `create_for_external_activity`. The `Bearer/JWT` prefix routes through Devise's `JwtBearerTokenAuthenticatable` strategy, which has no referer check, and through `check_for_auth_token` Case 1 (JWT decoding).

Relevant PRs: [#2494](https://github.com/concord-consortium/collaborative-learning/pull/2494) (standalone auth), [#2507](https://github.com/concord-consortium/collaborative-learning/pull/2507) (introduced `createPortalOffering`), [#2534](https://github.com/concord-consortium/collaborative-learning/pull/2534) (added `rule: "clue-standalone"`).

### Approach 4: Determine whether ALB/CloudFront logs exist

The unification design doc's log analysis (see `2026-02-26-peer-to-peer-auth-removal-research.md`) used CloudWatch Logs Insights on the `learn-ecs-production` log group (Rails application logs). ALB access logs would capture referer headers and response codes, but they appear not to be enabled.

**Checking ALB access log configuration:**

```bash
# Check ALB attributes for access logging
aws elbv2 describe-load-balancer-attributes \
  --load-balancer-arn <arn> \
  --query "Attributes[?Key=='access_logs.s3.enabled']"
```

If ALB access logs are enabled but being sent to an unexpected S3 bucket, they might exist and just need to be found. Worth checking.

---

## Findings

### Production Client `domain_matchers` (queried 2026-03-02)

| ID | Enforces? | Name | `domain_matchers` |
|---|---|---|---|
| 29 | **ENFORCES** | Activity Player | `"activity-player.concord.org\r\n"` |
| 13 | **ENFORCES** | Concord GH Pages | `"concord-consortium.github.io"` |
| 12 | **ENFORCES** | DEFAULT_REPORT_SERVICE_CLIENT | `"portal-report.concord.org concord-consortium.github.io localhost"` |
| 19 | **ENFORCES** | Digital Inscriptions Dashboard | `"collaborative-learning.concord.org"` |
| 14 | **ENFORCES** | external reports | `"reports.concord.org\r\n"` |
| 20 | **ENFORCES** | Geniventure Dashboard | `"geniventure-dashboard.concord.org"` |
| 21 | **ENFORCES** | Glossary Authoring | `"glossary-plugin.concord.org"` |
| 26 | **ENFORCES** | Portal Report SPA | `"portal-report.concord.org\r\nlocalhost"` |
| 23 | **ENFORCES** | vortex | `"models-resources.concord.org"` |
| 15 | **ENFORCES** | Weather Dashboard | `"weather.concord.org\r\n"` |
| 11 | no check | admin_api_user_client | nil |
| 27 | no check | Athena Researcher Reports | `""` |
| 2 | no check | authoring | `""` |
| 4 | no check | authoring-dev | nil |
| 3 | no check | authoring-staging | nil |
| 18 | no check | AWS Learner Logs | `""` |
| 30 | no check | CLUE | `""` |
| 7 | no check | CODAP Document Server | `""` |
| 16 | no check | CollabSpace Dashboard | `""` |
| 17 | no check | dataflow | `""` |
| 9 | no check | document-store-inquiryspace | nil |
| 1 | no check | localhost | `""` |
| 22 | no check | model-my-watershed | `""` |
| 28 | no check | Report Service Collaboration | `""` |
| 31 | no check | Research Report Server | `""` |

**Key finding for Step 1:** The Clients used by callers of the four migrated endpoints all have blank `domain_matchers`:

| Caller | Client | `domain_matchers` | Referer enforced? |
|---|---|---|---|
| LARA (publishing) | authoring (ID 2) | `""` | No |
| LARA (publishing) | authoring-staging (ID 3) | nil | No |
| LARA (publishing) | authoring-dev (ID 4) | nil | No |
| CLUE (standalone) | CLUE (ID 30) | `""` | No |

Even if LARA were sending raw AccessGrant bearer tokens (rather than using `token_authenticatable`), the referer check would pass because the LARA Clients don't enforce it.

### Risk assessment by controller

**BookmarksController and TeacherClassesController — NO RISK**

These endpoints are called only by the Portal's own React frontend components. The React components make same-origin requests without `Authorization` headers — they rely on session cookies. The request goes through Devise's `database_authenticatable` strategy (session-based), not `bearer_token_authenticatable`. The referer check is never reached.

Both controllers currently call `check_for_auth_token` (via `check_auth` and `auth_teacher` wrappers respectively), which falls through to the session fallback (Case 3: `current_user`). Migrating to `current_user` directly produces identical behavior — the code path already resolves to the same session-based user.

**ExternalActivitiesController — NO RISK**

Only LARA calls this endpoint, for publishing activities. The database query confirms that all three LARA Clients (IDs 2, 3, 4) have blank `domain_matchers`. This means `enforce_referrer?` returns false and `valid_from_referer?` always returns true — the referer check is a no-op regardless of how LARA authenticates or whether it sends a Referer header.

**OfferingsController (`create_for_external_activity` only) — NO RISK**

Only CLUE calls this endpoint (the "CLUE Standalone" feature). CLUE exchanges its OAuth2 AccessGrant for a Portal JWT and sends `Authorization: Bearer/JWT <jwt>` — not a raw AccessGrant token. This routes through `JwtBearerTokenAuthenticatable` (no referer check) on the Devise side, and Case 1 (JWT) in `check_for_auth_token`. The `BearerTokenAuthenticatable` referer check is never reached.

See "CLUE Standalone auth chain" in Approach 3 above for the full trace.

### Authentication failure logging gap

When the Devise bearer strategy fails (for any reason — expired grant, missing client, referer mismatch), **nothing is logged** in production:

- `bearer_token_authenticatable.rb` calls `fail(:invalid_token)` with no logging
- Production log level is `:info` (`config/environments/production.rb:31`)
- Devise/Warden debug-level logs are suppressed
- `CustomFailure` (`lib/custom_failure.rb`) processes the failure without logging
- `Rack::ResponseLogger` (`lib/rack/response_logger.rb`) only logs queue time from `X-REQUEST-START`

This means we have no visibility into how often the referer check is currently rejecting requests that `check_for_auth_token` then accepts. Adding temporary logging (Approach 2) would provide this visibility.

---

## Open Questions

### 1. Are ALB access logs enabled but stored somewhere unexpected?

**Action:** Check ALB attributes via AWS CLI or console. If logs exist, they would show Referer headers on all requests, providing a comprehensive picture. This is a general-purpose infrastructure question, not a blocker for Step 1.

### 2. Should we add temporary referer-check logging (independent of Step 1)?

The database query shows the four migrated controllers are safe, so this is **not a blocker for Step 1**. However, temporary logging in the Devise bearer strategy could still be independently useful — it would surface silent auth failures across the entire app (e.g., for report launches where 10 of 25 Clients DO enforce referer). This is an optional improvement, not a prerequisite.

---

## Conclusion

**Referer validation is not a blocker for Step 1.** All four controllers can be safely migrated from `check_for_auth_token` to `current_user`:

| Controller | Caller | Auth path | Referer risk |
|---|---|---|---|
| BookmarksController | Portal React (session) | Session cookies → `database_authenticatable` | **None** — no Bearer token |
| TeacherClassesController | Portal React (session) | Session cookies → `database_authenticatable` | **None** — no Bearer token |
| ExternalActivitiesController | LARA (publishing) | AccessGrant or `token_authenticatable` | **None** — LARA Clients have blank `domain_matchers` |
| OfferingsController (`create_for_external_activity`) | CLUE Standalone | Portal JWT → `JwtBearerTokenAuthenticatable` | **None** — JWT path, no referer check |

The referer check in `BearerTokenAuthenticatable` is only relevant for Clients with non-blank `domain_matchers` (10 of 25 production Clients). None of those 10 Clients are used by callers of the four migrated endpoints.

---

## Resolved Questions

### What are the `domain_matchers` values for all production Clients?

**Answer: Queried 2026-03-02.** See "Production Client `domain_matchers`" table in Findings. Of 25 Clients, 10 enforce referer checks. None of the Clients used by callers of the four migrated endpoints enforce referer. The LARA Clients (IDs 2, 3, 4) all have blank `domain_matchers`; the CLUE Client (ID 30) also has blank `domain_matchers`.

### How does LARA authenticate when publishing to `api/v1/external_activities`?

**Answer: Does not matter — LARA's Clients have blank `domain_matchers`, so the referer check is a no-op regardless of auth mechanism.**

The peer-to-peer research doc notes LARA uses `user.authentication_token` (not `app_secret`) for publishing. Whether this token is sent as a query parameter (via `token_authenticatable`) or as `Authorization: Bearer` (via `bearer_token_authenticatable`), the LARA Clients (IDs 2, 3, 4) have blank `domain_matchers`, so `valid_from_referer?` always returns true.

### How does CLUE authenticate when calling `create_for_external_activity`?

**Answer: Portal JWT via `Bearer/JWT` header. No AccessGrant token is used. No referer check is involved.**

CLUE's "Standalone" feature performs an OAuth2 implicit grant to get an AccessGrant token, immediately exchanges it for a Portal JWT via `GET /api/v1/jwt/portal`, and uses the JWT for all subsequent API calls including `create_for_external_activity`. The `createPortalOffering()` function in `src/lib/portal-api.ts` sends `Authorization: Bearer/JWT <jwt>`. Verified by reading the CLUE source code and PRs [#2494](https://github.com/concord-consortium/collaborative-learning/pull/2494), [#2507](https://github.com/concord-consortium/collaborative-learning/pull/2507), [#2534](https://github.com/concord-consortium/collaborative-learning/pull/2534).
