# Add `iss` Claim to Portal JWTs and Improve Devise Strategy Error Handling

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add an `iss` (issuer) claim to portal JWTs using `APP_CONFIG[:site_url]`, then use it in the JWT Devise strategy to distinguish portal tokens from other JWTs, enabling proper `fail!` (halt) vs `fail` (pass-through) semantics and distinct error messages for expired vs invalid tokens.

**Architecture:** Add `iss` to `SignedJwt.create_portal_token`. Update the JWT strategy's `valid?` to only claim tokens that are ours (by `iss`, or by `uid` presence for legacy tokens). Once `valid?` guarantees ownership, `authenticate!` uses `fail!` for all failures with distinct messages for expired vs invalid signature. The OIDC strategy remains unchanged — it already uses soft `fail` correctly.

**Tech Stack:** Ruby, JWT gem, Devise/Warden, RSpec

---

## Context

Portal JWTs and Google OIDC JWTs can both arrive as `Bearer <jwt-with-dots>`. Currently, the JWT Devise strategy uses soft `fail` for all errors, which was needed so OIDC tokens could cascade to the next strategy. But this means expired portal tokens also cascade instead of being definitively rejected. The root issue: the strategy can't distinguish "this is our token and it's bad" from "this isn't our token."

Adding an `iss` claim to portal tokens solves this cleanly. The `iss` claim is the standard JWT mechanism for identifying token origin (RFC 7519). Google uses `accounts.google.com`, Auth0 uses tenant URLs, etc. Using `APP_CONFIG[:site_url]` follows this convention.

---

## Task 1: Add `iss` claim to `SignedJwt.create_portal_token`

**Files:**
- Modify: `rails/lib/signed_jwt.rb:8-22`

**Step 1: Write the failing test**

Add a test in the existing spec file (`rails/spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb`) or create a new spec for `SignedJwt` if one doesn't exist. The test should verify that `create_portal_token` includes `iss: APP_CONFIG[:site_url]` in the payload.

```ruby
# In a new or existing SignedJwt spec
it 'includes iss claim set to APP_CONFIG[:site_url]' do
  token = SignedJwt.create_portal_token(user, {}, 3600)
  decoded = JWT.decode(token, nil, false).first
  expect(decoded['iss']).to eq(APP_CONFIG[:site_url])
end
```

**Step 2: Run test to verify it fails**

Run: `docker compose run --rm app bundle exec rspec spec/libs/signed_jwt_spec.rb -v` (or wherever the test is placed)
Expected: FAIL — `iss` is nil

**Step 3: Write minimal implementation**

In `rails/lib/signed_jwt.rb`, add `iss` to the payload in `create_portal_token`:

```ruby
def self.create_portal_token(user, claims={}, expires_in=3600)
  now = Time.now.to_i
  payload = {
    alg: self.hmac_algorithm,
    iss: APP_CONFIG[:site_url],
    iat: now,
    exp: now + expires_in,
    uid: user.id
  }
  # ... rest unchanged
end
```

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```
feat: add iss claim to portal JWTs
```

---

## Task 2: Update JWT strategy `valid?` to check token ownership

**Files:**
- Modify: `rails/lib/jwt_bearer_token_authenticatable.rb:4-6`

**Step 1: Write the failing tests**

Add tests to `rails/spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb`:

```ruby
context 'valid? with token ownership' do
  it 'returns true for a token with matching iss' do
    # token created by SignedJwt now has iss: APP_CONFIG[:site_url]
    expect(strategy.valid?).to be true
  end

  it 'returns true for a legacy token without iss but with uid (backward compat)' do
    # Manually create a token without iss but with uid
    legacy_payload = { alg: 'HS256', iat: Time.now.to_i, exp: Time.now.to_i + 600, uid: user.id }
    legacy_token = JWT.encode(legacy_payload, ENV['JWT_HMAC_SECRET'], 'HS256')
    allow(request).to receive(:headers).and_return({"Authorization" => "Bearer/JWT #{legacy_token}"})
    expect(strategy.valid?).to be true
  end

  it 'returns false for a token with a different iss and no uid' do
    # e.g., a Google OIDC token
    other_payload = { iss: 'https://accounts.google.com', sub: '12345', exp: Time.now.to_i + 600 }
    other_token = JWT.encode(other_payload, 'wrong-key', 'HS256')
    allow(request).to receive(:headers).and_return({"Authorization" => "Bearer #{other_token}"})
    expect(strategy.valid?).to be false
  end
end
```

**Step 2: Run tests to verify they fail**

**Step 3: Write minimal implementation**

```ruby
def valid?
  return false unless has_jwt_bearer_token?
  # Peek at unverified payload to check ownership
  unverified = JWT.decode(jwt_token_value, nil, false).first rescue nil
  return false unless unverified
  # Ours if iss matches, or legacy token with uid but no iss
  unverified['iss'] == APP_CONFIG[:site_url] || (unverified.key?('uid') && !unverified.key?('iss'))
end
```

**Step 4: Run tests to verify they pass**

**Step 5: Commit**

```
feat: JWT strategy valid? checks token ownership via iss claim
```

---

## Task 3: Update `authenticate!` to use `fail!` with distinct error messages

**Files:**
- Modify: `rails/lib/jwt_bearer_token_authenticatable.rb:8-23`
- Modify: `rails/lib/jwt_bearer_token_authenticatable.rb:27-34` (decode_token)

Since `valid?` now guarantees the token is ours, all failures in `authenticate!` should use `fail!` (halting). Additionally, distinguish expired tokens from invalid signatures.

**Step 1: Write the failing tests**

Update existing tests and add new ones in `rails/spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb`:

```ruby
context 'a user with an expired authentication token' do
  let(:expires_in) { -10.minutes.to_i }
  it 'should halt the chain with fail!' do
    strategy.authenticate!
    expect(strategy).to be_halted
  end
  it 'should set :token_expired message' do
    strategy.authenticate!
    expect(strategy.message).to eq(:token_expired)
  end
end

context 'a token with invalid signature' do
  let(:token) { JWT.encode({ uid: user.id, iss: APP_CONFIG[:site_url], exp: Time.now.to_i + 600 }, 'wrong-secret', 'HS256') }
  it 'should halt the chain with fail!' do
    strategy.authenticate!
    expect(strategy).to be_halted
  end
  it 'should set :invalid_token message' do
    strategy.authenticate!
    expect(strategy.message).to eq(:invalid_token)
  end
end
```

**Step 2: Run tests to verify they fail**

**Step 3: Write minimal implementation**

Update `decode_token` to raise distinct errors:

```ruby
def decode_token
  return nil unless has_jwt_bearer_token?
  token = jwt_token_value
  SignedJwt::decode_portal_token(token)
rescue JWT::ExpiredSignature => e
  Rails.logger.warn("JwtBearerToken: token expired - #{e.message}")
  raise
rescue SignedJwt::Error => e
  Rails.logger.warn("JwtBearerToken: decode error - #{e.message}")
  raise
end
```

Update `authenticate!`:

```ruby
def authenticate!
  decoded_token = decode_token
  unless decoded_token && decoded_token[:data].key?("uid")
    Rails.logger.warn("JwtBearerToken: token decode failed or missing uid")
    return fail!(:invalid_token)
  end
  user = User.find_by_id(decoded_token[:data]["uid"])
  unless user
    Rails.logger.warn("JwtBearerToken: user not found for uid=#{decoded_token[:data]['uid']}")
    return fail!(:invalid_token)
  end
  request.env['portal.auth_strategy'] = 'jwt_bearer_token'
  success!(user)
rescue JWT::ExpiredSignature
  fail!(:token_expired)
rescue SignedJwt::Error
  fail!(:invalid_token)
end
```

**Step 4: Run tests to verify they pass**

**Step 5: Also verify existing tests still pass**

Run: `docker compose run --rm app bundle exec rspec spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb -v`

**Step 6: Commit**

```
feat: JWT strategy uses fail! with distinct expired vs invalid messages
```

---

## Task 4: Update design docs

**Files:**
- Modify: `docs/specs/2026-02-25-portal-oidc-authentication-design.md`
- Modify: `docs/portal-authentication-unification-design.md`

### 4a: Update OIDC design doc

Update Section 1 ("Strategy ordering") to reflect the new behavior:
- The JWT strategy now uses `fail!` (halting) because `valid?` ensures it only fires for portal tokens
- The OIDC strategy continues to use `fail` (non-halting) since it's the last JWT-based strategy
- The `valid?` check now inspects the `iss` claim rather than just checking for a Bearer token with dots
- Remove or update the "Implementation note" about changing `fail!` to `fail`

### 4b: Update authentication unification doc

Add a new subsection documenting the inconsistency between how Devise strategies and `check_for_auth_token` report auth failures:

**The inconsistency:** When the JWT Devise strategy rejects a token, `fail!(:token_expired)` or `fail!(:invalid_token)` stores a message symbol in Warden, but `CustomFailure` (the Warden failure app) does not surface these messages in JSON API responses. The client receives a generic 401. By contrast, `check_for_auth_token` (used by `JwtController`) raises `SignedJwt::Error` exceptions, and `JwtController`'s `rescue_from` renders the exception message directly — so clients get specific error messages like "Signature has expired".

This means:
- `JwtController` endpoints: clients see specific error reasons (expired, invalid, etc.)
- All other API endpoints (using Devise `current_user`): clients see only a generic 401/403

**Add a new next step** (after the existing next steps in Section 8) proposing unified JSON error responses for API auth failures. This could be:
- A `before_action` in `API::APIController` that checks `warden.message` after failed auth and renders a JSON body with the failure reason
- Or updating `CustomFailure` to return JSON with the failure symbol for API-format requests
- The goal: all API endpoints return consistent, informative error responses regardless of which auth path they use

**Step 1: Update both docs**

**Step 2: Commit**

```
docs: update design docs for iss-based strategy routing and error response inconsistency
```

---

## Task 5: Run full related test suite

Run all related specs to ensure nothing is broken:

```bash
docker compose run --rm app bundle exec rspec \
  spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb \
  spec/controllers/api/api_controller_spec.rb \
  spec/requests/api/v1/oidc_auth_spec.rb \
  -v
```

Expected: All pass.

---

## Verification

1. **Unit tests**: New and updated tests in `jwt_bearer_token_authenticatable_spec.rb` cover:
   - `valid?` returns true for portal tokens (with `iss`)
   - `valid?` returns true for legacy tokens (with `uid`, no `iss`)
   - `valid?` returns false for non-portal tokens (different `iss`, no `uid`)
   - `authenticate!` halts with `:token_expired` for expired portal tokens
   - `authenticate!` halts with `:invalid_token` for bad-signature portal tokens
   - Existing success/failure tests still pass

2. **Integration tests**: `oidc_auth_spec.rb` still passes — OIDC tokens are no longer claimed by the JWT strategy's `valid?`, so the cascade works correctly

3. **API controller tests**: `api_controller_spec.rb` still passes — `check_for_auth_token` behavior is unchanged (it does its own decode, independent of Devise strategies)

## Key files

| File | Change |
|---|---|
| `rails/lib/signed_jwt.rb` | Add `iss: APP_CONFIG[:site_url]` to payload |
| `rails/lib/jwt_bearer_token_authenticatable.rb` | New `valid?` with ownership check, `fail!` in `authenticate!`, distinct error handling |
| `rails/spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb` | New tests for ownership, expiry, invalid signature |
| `docs/specs/2026-02-25-portal-oidc-authentication-design.md` | Update strategy ordering section |
| `docs/portal-authentication-unification-design.md` | Document error response inconsistency + new next step |
