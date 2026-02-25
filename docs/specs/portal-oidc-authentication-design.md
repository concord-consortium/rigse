# Portal OIDC Authentication — Detailed Design

**Date:** 2026-02-25
**Status:** Draft

## Overview

The Portal (rigse) needs to accept API requests authenticated by a Google Cloud service account's OIDC token. This allows trusted services — such as Firebase Cloud Functions — to call Portal APIs with elevated permissions (e.g., adding a student to a class) without shared secrets.

### Motivation

The immediate use case is the button interactive, where a Cloud Function checks assignment completion and then performs Portal operations (class membership, email, assignment unlocking) on behalf of a project admin. The OIDC authentication mechanism itself is general-purpose: any Google Cloud service account can be registered as a trusted caller and mapped to a Portal user.

For the overall button interactive authentication architecture, see the auth design doc in the question-interactives repository.

### What this design adds

- A new Devise/Warden authentication strategy for Google OIDC bearer tokens
- A JWKS verification module using the existing `jwt` gem
- A database table and admin UI mapping service account identities to Portal users

### Scope

This document covers the OIDC verification middleware and a sketch of how the existing `add_to_class` endpoint works with it. It does not cover new Portal API endpoints that callers might need — those would be designed separately.

---

## 1. Devise Strategy: `OidcBearerTokenAuthenticatable`

A new Devise/Warden strategy that intercepts `Authorization: Bearer <token>` requests, detects when the token is a Google OIDC JWT (rather than an AccessGrant), and authenticates.

**File:** `rails/lib/oidc_bearer_token_authenticatable.rb`

### Detection logic

The existing `BearerTokenAuthenticatable` Devise strategy also matches `Authorization: Bearer <token>` and looks up an `AccessGrant`. To avoid conflict, the OIDC strategy distinguishes tokens by format: OIDC JWTs contain dots (header.payload.signature) while AccessGrant tokens are opaque strings.

### Strategy flow

1. **`valid?`** — Returns `true` if `Authorization: Bearer <token>` is present and the token contains dots (looks like a JWT).
2. **`authenticate!`** — Decodes the JWT header to check `iss` is `accounts.google.com`, then verifies the full token via JWKS (see Section 2). On success, looks up the `sub` claim in the service account mapping table (see Section 3). If a mapped Portal user is found, calls `success!(user)` which sets `current_user`. On any failure, calls `fail(:invalid_token)`.

### Registration

Add `:oidc_bearer_token_authenticatable` to the User model's `devise` declaration, after the existing strategies:

```ruby
devise :database_authenticatable, :registerable, :token_authenticatable,
       :confirmable, :bearer_token_authenticatable, :jwt_bearer_token_authenticatable,
       :oidc_bearer_token_authenticatable,
       # ... rest of existing strategies
```

### Strategy ordering

Devise/Warden tries strategies in declaration order. The OIDC strategy is listed after the existing `bearer_token_authenticatable` and `jwt_bearer_token_authenticatable`. The `valid?` check (JWT-shaped `Bearer` token) ensures it only fires when appropriate:

- `Bearer <opaque-string>` — handled by `BearerTokenAuthenticatable` (AccessGrant lookup)
- `Bearer/JWT <token>` — handled by `JwtBearerTokenAuthenticatable` (Portal HMAC JWT)
- `Bearer <jwt-with-dots>` — handled by `OidcBearerTokenAuthenticatable` (Google OIDC)

### Why `Bearer` and not a custom scheme like `Bearer/OIDC`

This codebase already uses a non-standard authorization scheme: Portal HMAC JWTs are sent as `Authorization: Bearer/JWT <token>` rather than the standard `Authorization: Bearer <token>`. The `Bearer/JWT` convention was introduced specifically to distinguish Portal JWTs from AccessGrant opaque tokens, since both would otherwise arrive as `Bearer <token>`. A comment in the code explains this: `# use bearer/jwt to distinguish from client bearer tokens`.

Given that precedent, it's reasonable to ask whether OIDC tokens should use `Bearer/OIDC` or similar. Here's why this design uses standard `Bearer` instead:

**The standard says `Bearer`.** [RFC 6750](https://datatracker.ietf.org/doc/html/rfc6750) defines `Authorization: Bearer <token>` as the HTTP authorization scheme for bearer tokens. The `Bearer/JWT` scheme used elsewhere in this codebase is non-standard — it is a custom convention specific to this project. Most services that accept multiple token types (Google, AWS, Auth0, etc.) use plain `Bearer` for all of them and distinguish tokens by inspecting the token content, not the scheme name.

**Google's libraries support both approaches.** The Cloud Function will use Google's `google-auth-library` (Node.js) to obtain OIDC tokens. There are two ways to use it:

- **High-level API** (`getIdTokenClient` + `client.fetch()`): Automatically injects `Authorization: Bearer <token>`. This API does not support customizing the header format.
- **Manual approach** (`fetchIdToken` to get the raw token string): The function gets the token as a string and constructs its own HTTP request, setting whatever `Authorization` header it wants. Using `Bearer/OIDC` this way is straightforward — maybe 2-3 extra lines of code.

So a custom scheme is practical, not blocked by the libraries. The high-level API is slightly more convenient with standard `Bearer`, but the difference is small.

**OIDC tokens are structurally distinguishable.** An OIDC JWT is easy to identify without a custom scheme: it contains dots (header.payload.signature), and its decoded header has `iss: accounts.google.com`. The Devise strategy's `valid?` method can reliably detect these tokens without ambiguity. There is no case where a valid AccessGrant token would be mistaken for an OIDC JWT or vice versa — AccessGrant tokens are opaque strings without dots.

**The existing `Bearer/JWT` convention is arguably technical debt, not a pattern to extend.** The `Bearer/JWT` scheme was a pragmatic solution to a real problem (two token types sharing the same `Bearer` header), but it diverges from how the rest of the ecosystem works. Adding `Bearer/OIDC` would deepen that divergence. If anything, the long-term direction would be to migrate Portal JWTs back to standard `Bearer` and distinguish all token types by content inspection — but that's out of scope here.

**Counterargument: explicitness.** The strongest argument for `Bearer/OIDC` is that it makes the token type immediately visible in logs, debug headers, and code — no need to decode the token to know what it is. It also makes the Devise strategy ordering less fragile, since each strategy matches on a distinct scheme prefix rather than relying on content-based detection. This is a legitimate benefit, and if the team prefers consistency with the existing `Bearer/JWT` convention over alignment with the RFC, the design can be adjusted — the verification logic would be identical either way, only the `valid?` check and caller header format would change.

**Decision: use standard `Bearer`.** This design follows the RFC convention. The structural distinguishability of OIDC tokens makes a custom scheme unnecessary, and aligning with the standard keeps the door open for any future OIDC caller to use Google's libraries without customization.

---

## 2. JWKS Verification: `GoogleOidcVerifier`

A new module that fetches Google's public keys and verifies OIDC tokens using the `jwt` gem (already a dependency).

**File:** `rails/lib/google_oidc_verifier.rb`

> **Design note:** Google's official `googleauth` gem (`Google::Auth::IDTokens.verify_oidc`) provides this
> functionality in a single method call. We chose direct implementation with the `jwt` gem to avoid pulling
> in a large dependency tree (faraday, signet, google-cloud-env, etc.) for one function. The `jwt` gem is
> already used in this codebase for both HMAC and RSA JWT operations (see `lib/signed_jwt.rb`). If
> maintenance burden becomes a concern, `googleauth` is a drop-in replacement:
> https://github.com/googleapis/google-auth-library-ruby

### Token verification steps

1. Decode the JWT header (without verification) to get the `kid` (key ID).
2. Look up the matching public key from the cached JWKS keyset.
3. If no matching key is found, refresh the JWKS once (handles key rotation), then retry.
4. Verify the JWT signature using RS256 and the matched public key.
5. Validate standard claims:
   - `iss` must be `accounts.google.com` or `https://accounts.google.com`
   - `aud` must match `APP_CONFIG[:site_url]` (see "Audience configuration" below)
   - `exp` must be in the future (with ~30 seconds clock-skew tolerance)
   - `iat` must be in the past (with ~30 seconds clock-skew tolerance)
6. Return the decoded payload (containing `sub`, `email`, etc.).

### JWKS caching

- Fetch from `https://www.googleapis.com/oauth2/v3/certs` using `Net::HTTP` (already used in the codebase).
- Cache in a module-level instance variable with a TTL of 1 hour.
- On cache miss or expired cache: fetch fresh keys.
- On key-not-found with valid cache: fetch fresh keys once (key rotation scenario), then fail if still not found.
- On fetch failure with valid (even expired) cache: use stale keys rather than rejecting all requests.
- On fetch failure with no cache: raise an error.

### Audience configuration

The expected `aud` claim is derived from `APP_CONFIG[:site_url]`, which is already configured per environment in `rails/config/settings.yml`:

- **Development:** `ENV["SITE_URL"] || 'http://localhost:3000'`
- **Staging:** `http://rails-portal.staging.concord.org`
- **Production:** `http://learn.concord.org`

No new environment variable is needed. When minting OIDC tokens for testing, use the value from `APP_CONFIG[:site_url]` as the `--audiences` argument (see Section 5).

---

## 3. Service Account Mapping: `Admin::OidcClient`

A database table mapping Google service account identities to Portal users.

### Schema: `admin_oidc_clients`

| Column | Type | Notes |
|---|---|---|
| `id` | bigint | Primary key |
| `name` | string, not null | Human-readable label, e.g., "Button Function (staging)" |
| `sub` | string, not null | Google's stable unique ID for the service account. Primary lookup key. Indexed, unique. |
| `email` | string | Service account email, e.g., `button-func@project.iam.gserviceaccount.com`. Stored for display/debugging, not used for auth matching. |
| `user_id` | integer, not null | Foreign key to `users` table. The Portal user this service account acts as. |
| `active` | boolean, not null | Kill switch — set to false to revoke access without deleting the record. Default `true`. |
| `created_at` | datetime | |
| `updated_at` | datetime | |

### Model

**File:** `rails/app/models/admin/oidc_client.rb`

- `belongs_to :user`
- Validates presence of `name`, `sub`, `user_id`
- Validates uniqueness of `sub`
- Scope: `active` — `where(active: true)`
- Extends `SearchableModel` following existing admin model patterns

### Lookup flow

Called from the Devise strategy after token verification:

1. `Admin::OidcClient.active.find_by(sub: decoded_token["sub"])`
2. If found, return `oidc_client.user`
3. If not found, authentication fails

### Why `sub` and not `email`

The `sub` claim is a stable, Google-assigned unique ID for the service account. The `email` claim can theoretically be renamed or aliased. Using `sub` as the canonical identifier is more robust. The `email` is stored alongside for human readability in the admin UI.

### Admin UI

Standard CRUD following the existing admin pattern:

- **Controller:** `rails/app/controllers/admin/oidc_clients_controller.rb` — `include RestrictedController`, `before_action :admin_only`
- **Policy:** `rails/app/policies/admin/oidc_client_policy.rb`
- **Views:** `rails/app/views/admin/oidc_clients/` — HAML templates (index, show, new, edit, _form)
- **Routes:** `resources :oidc_clients` under the existing `namespace :admin` block

The form includes text fields for `name`, `sub`, `email`, and `user_id` (integer input, not a dropdown — there are thousands of Portal users). The `active` field is a checkbox.

### Naming rationale

`OidcClient` follows the existing `Admin::Client` pattern (which manages OAuth app registrations). The concept is similar — an external identity authorized to call Portal APIs.

---

## 4. Interaction with `check_for_auth_token`

### Current state

The OIDC Devise strategy sets `current_user` automatically. Any endpoint that uses Pundit authorization via `current_user` directly — such as `add_to_class` — works with OIDC out of the box. No changes to `check_for_auth_token` are needed for these endpoints.

### The overlap problem

Several existing API endpoints bypass Devise's `current_user` and instead call `check_for_auth_token()` manually (defined in `API::APIController`) to extract both the user and a role hash (learner/teacher context) from the token. These endpoints include offerings, external activities, teacher classes, bookmarks, and JWT.

OIDC-authenticated callers (such as the button interactive's Cloud Function) will likely need access to some of these endpoints in the future — at least offerings and teacher classes.

The overlap is problematic because:

- `check_for_auth_token` parses the `Authorization` header independently from Devise, using its own matching logic.
- It returns role information (learner/teacher associations) embedded in the token — information that doesn't exist in an OIDC token and isn't captured by the Devise strategy.
- Simply reordering branches (e.g., checking `current_user` first) would break the JWT path, which depends on extracting role data from the token claims.
- The two auth paths (Devise strategies vs. manual `check_for_auth_token`) have subtly different behavior (e.g., referer checking) that makes unification non-trivial.

### Decision

Don't modify `check_for_auth_token` as part of this work. The initial set of endpoints that OIDC callers need (e.g., `add_to_class`) work through Devise/Pundit without it. A separate design doc will investigate options for resolving the overlap before OIDC callers need endpoints that go through `check_for_auth_token`.

---

## 5. Endpoint Sketch: Verifying with `add_to_class`

The `add_to_class` endpoint already exists. This section documents how the Cloud Function would call it and what the Portal does, to confirm the OIDC middleware integrates correctly.

### Request

```
POST /api/v1/students/add_to_class
Authorization: Bearer <Google OIDC token>
Content-Type: application/json

{
  "clazz_id": 123,
  "student_id": 456
}
```

### What happens on the Portal side

1. Devise tries strategies in order. `BearerTokenAuthenticatable` finds no matching `AccessGrant` — fails, moves on. `JwtBearerTokenAuthenticatable` sees the header is `Bearer` not `Bearer/JWT` — `valid?` returns false, skips. `OidcBearerTokenAuthenticatable` detects a JWT-shaped Bearer token, verifies the OIDC signature via JWKS, looks up the `sub` in `admin_oidc_clients`, finds the mapped Portal user, calls `success!(user)`.
2. `current_user` is now the mapped Portal user (e.g., a project admin account).
3. The `add_to_class` action calls `authorize portal_clazz, :update_roster?` — Pundit checks whether the mapped user has permission to modify this class's roster.
4. It calls `authorize student, :show?` — Pundit checks whether the mapped user can see this student.
5. If both pass, `student.add_clazz(portal_clazz)` runs and the student is added.

### Verification plan

#### Local dev testing

1. Start the Portal locally (e.g., `http://localhost:3000` or whatever port is configured).
2. Create an `Admin::OidcClient` record in the local database mapping a test service account's `sub` to a local admin user.
3. Check the expected audience value from a Rails console:
   ```ruby
   APP_CONFIG[:site_url]
   ```
   Note: in environments like GitHub Codespaces, the browser URL (e.g., `https://<codespace>-3000.app.github.dev`) differs from `APP_CONFIG[:site_url]` (likely `http://localhost:3000`). The OIDC audience must match what the Portal has configured, not the browser URL, because verification happens server-side.
4. Obtain an OIDC token using gcloud:
   ```
   gcloud auth print-identity-token \
     --impersonate-service-account=<service-account-email> \
     --audiences=<APP_CONFIG[:site_url] value>
   ```
   The service account email is from the GCP project (e.g., `report-service-dev`). To find existing service accounts:
   ```
   gcloud iam service-accounts list --project=report-service-dev
   ```
   To create one if needed:
   ```
   gcloud iam service-accounts create button-function \
     --project=report-service-dev \
     --display-name="Button Interactive Function"
   ```
   The `--impersonate-service-account` flag requires your personal Google account to have the `roles/iam.serviceAccountTokenCreator` role on that service account.
5. Call the endpoint:
   ```
   curl -X POST http://localhost:3000/api/v1/students/add_to_class \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{"clazz_id": ..., "student_id": ...}'
   ```
6. Confirm the student is added to the class.
7. Confirm that an expired/invalid/wrong-audience token is rejected.

#### Staging verification

Same approach, but against the staging Portal URL with its configured `site_url`. Create the `Admin::OidcClient` record through the admin UI.

---

## 6. Testing Strategy

### Unit tests

**`GoogleOidcVerifier`** — Test the verification module in isolation:
- Valid token with matching `kid`, valid signature, valid claims — returns decoded payload
- Expired token — raises error
- Wrong `aud` — raises error
- Wrong `iss` — raises error
- Unknown `kid` triggers one JWKS refresh, then fails if still unknown
- JWKS fetch failure with valid cached keys — uses stale cache
- JWKS fetch failure with no cache — raises error
- Use pre-generated RSA key pairs and locally-constructed JWTs rather than hitting Google's real JWKS endpoint. Mock `Net::HTTP` calls.

**`OidcBearerTokenAuthenticatable` Devise strategy** — Test the Warden strategy:
- No `Authorization` header — `valid?` returns false (skipped)
- `Bearer <opaque-string>` (no dots) — `valid?` returns false (falls through to existing strategies)
- `Bearer <valid-oidc-jwt>` with matching `Admin::OidcClient` — authenticates, sets `current_user` to mapped user
- `Bearer <valid-oidc-jwt>` with no matching `Admin::OidcClient` — fails authentication
- `Bearer <valid-oidc-jwt>` with inactive `Admin::OidcClient` — fails authentication
- `Bearer/JWT <portal-jwt>` — `valid?` returns false (not our format)

**`Admin::OidcClient` model** — Standard model tests:
- Validates presence of `name`, `sub`, `user_id`
- Validates uniqueness of `sub`
- `active` scope returns only active records
- `belongs_to :user` association

### Integration test

Request spec that sends a `Bearer` OIDC token to `POST /api/v1/students/add_to_class`, with a seeded `Admin::OidcClient` record and test RSA keys standing in for Google's JWKS. Confirm the student gets added. Confirm a missing/invalid/expired token returns 401.

### What's NOT tested here

- Real Google OIDC tokens against real JWKS — that's the manual verification from Section 5, done during deployment to staging.
- The `check_for_auth_token` overlap — out of scope per Section 4.

---

## 7. Security Considerations

### Fail-closed validation

Any verification failure (signature, expiration, issuer, audience, missing `sub`, no matching `Admin::OidcClient`, inactive client) results in the strategy calling `fail(:invalid_token)`. Warden moves on to the next strategy. If no strategy succeeds, the request is unauthenticated and Pundit's `authorize` call returns 403.

The strategy never raises exceptions that leak token contents or verification details to the caller. Error responses are generic: `{ success: false, message: "Not authorized" }`.

### Logging

- Log successful OIDC authentications at `info` level: the `Admin::OidcClient` name and mapped user ID (not the token itself).
- Log verification failures at `warn` level: the failure reason (expired, wrong audience, unknown sub, etc.) and the `email` claim if available for debugging — never the full token.
- Never log token values, signatures, or JWKS key material.

### Token replay

- The `aud` claim validation prevents tokens minted for other services from being replayed against the Portal.
- The `exp` claim limits the window for replaying a legitimately-issued token. Google OIDC tokens have a 1-hour lifetime by default.
- No additional replay protection (nonces, jti tracking) is needed at the auth layer. Individual endpoints can add application-level idempotency as appropriate.

### Kill switch

The `active` boolean on `Admin::OidcClient` allows immediately revoking a service account's access without redeploying or deleting records.

### No CSRF concerns

OIDC-authenticated requests are API calls with bearer tokens, not browser sessions. CSRF protection doesn't apply.

---

## Files to create or modify

| Action | File | Description |
|---|---|---|
| Create | `rails/lib/google_oidc_verifier.rb` | JWKS verification module |
| Create | `rails/lib/oidc_bearer_token_authenticatable.rb` | Devise/Warden strategy |
| Create | `rails/app/models/admin/oidc_client.rb` | Service account mapping model |
| Create | `rails/app/controllers/admin/oidc_clients_controller.rb` | Admin CRUD controller |
| Create | `rails/app/policies/admin/oidc_client_policy.rb` | Pundit policy |
| Create | `rails/app/views/admin/oidc_clients/` | HAML views (index, show, new, edit, _form) |
| Create | `rails/db/migrate/..._create_admin_oidc_clients.rb` | Migration |
| Create | `rails/spec/lib/google_oidc_verifier_spec.rb` | Verifier unit tests |
| Create | `rails/spec/lib/oidc_bearer_token_authenticatable_spec.rb` | Strategy unit tests |
| Create | `rails/spec/models/admin/oidc_client_spec.rb` | Model unit tests |
| Create | `rails/spec/requests/api/v1/oidc_auth_spec.rb` | Integration test |
| Modify | `rails/app/models/user.rb` | Add `:oidc_bearer_token_authenticatable` to devise declaration |
| Modify | `rails/config/routes.rb` | Add `resources :oidc_clients` under `namespace :admin` |
