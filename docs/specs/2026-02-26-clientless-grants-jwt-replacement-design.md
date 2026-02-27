# Client-less Grants JWT Replacement — Design

**Date:** 2026-02-26
**Status:** Approved
**Related:** `portal-authentication-unification-design.md` (Option B), `clientless-grants-replacement-research.md`

---

## Goal

Replace the two sites that create client-less `AccessGrant` records (short-lived launch tokens with a learner but no client) with stateless JWTs. This eliminates unnecessary database writes on every activity launch while keeping the same external behavior — runtimes treat the token as opaque.

## Why client-less grants are problematic

Client-less grants are `AccessGrant` records created without a `client_id`. They cause three problems documented in `portal-authentication-unification-design.md`:

1. **Authentication divergence.** The Portal has two parallel auth systems: Devise strategies (setting `current_user`) and the manual `check_for_auth_token` method. The Devise bearer strategy requires `grant.client` — so it rejects client-less grants entirely. These tokens can *only* be authenticated by `check_for_auth_token`, meaning any endpoint that relies on `current_user` cannot accept them. This creates a split where the same `Authorization: Bearer` header produces different results depending on which code path handles it.

2. **Security bypass.** The Devise bearer strategy validates the request referer against the client's `domain_matchers`. Client-less grants bypass this check entirely (no client → no domain_matchers → no validation). While the 3-minute expiry limits exposure, this is a gap in the security model.

3. **Unnecessary database writes.** Every activity launch creates an `AccessGrant` row that exists only to be looked up once (within 3 minutes) and then pruned. Replacing these with stateless JWTs eliminates the write, the lookup, and the pruning — the token is self-contained and cryptographically verified.

## Approach

Minimal / Approach 1: only modify `check_for_auth_token` and the two creation sites. Devise strategies are untouched. This keeps the PR small and sets up a clean base for a follow-up PR that continues the authentication unification work.

## Changes

### 1. Token creation (2 sites)

Replace `User#create_access_token_with_learner_valid_for` with `SignedJwt::create_portal_token`:

**`app/models/external_activity.rb:148-153`** — before:
```ruby
if append_auth_token
  AccessGrant.prune!
  token = learner.user.create_access_token_with_learner_valid_for(3.minutes, learner)
  append_query(uri, "token=#{token}")
  ...
end
```

After:
```ruby
if append_auth_token
  token = SignedJwt::create_portal_token(learner.user, {learner_id: learner.id, user_type: "learner"}, 180)
  append_query(uri, "token=#{token}")
  ...
end
```

**`app/services/api/v1/create_collaboration.rb:80-83`** — same pattern with `@owner_learner`.

Both drop the `AccessGrant.prune!` call (no grants being created).

### 2. Token routing in `check_for_auth_token`

Reorder the cases so JWT detection comes before AccessGrant lookup. Expand the `Bearer/JWT` case to also match `Bearer <token>` when the token contains dots.

**Why accept JWTs under the plain `Bearer` prefix:** The external runtimes already send tokens back as `Authorization: Bearer <token>` — that's the standard OAuth 2.0 Bearer Token usage per RFC 6750. We don't want to change the runtimes, and the `Bearer/JWT` prefix used elsewhere in the Portal is a non-standard convention. Accepting JWTs under plain `Bearer` avoids runtime changes and aligns with the RFC.

```ruby
if header && (header =~ /^Bearer\/JWT (.*)$/i || (header =~ /^Bearer (.+\..+)$/i))
  # JWT decode (existing Case D logic)
elsif header && header =~ /^Bearer (.*)$/i
  # AccessGrant lookup (existing Case A logic)
elsif current_user
  # session fallback
end
```

**Why this is safe:** AccessGrant tokens are `SecureRandom.hex(16)` (hex characters only, never contain dots). JWTs always contain dots (`header.payload.signature`). The format is unambiguous.

### 3. Cleanup

- Remove `User#create_access_token_with_learner_valid_for` — only called from the 2 sites being changed.
- Update specs for `external_activity`, `create_collaboration`, and `check_for_auth_token`.

## What's NOT changing

- **Devise strategies** — `bearer_token_authenticatable` and `jwt_bearer_token_authenticatable` are untouched.
- **`Bearer/JWT` prefix** — existing callers that send `Authorization: Bearer/JWT <token>` continue to work.
- **External runtimes** — no changes needed (all three active runtimes treat the token as opaque per the research doc).
- **`AccessGrant` model** — still used by OAuth clients with `client_id`.

## JWT in URL parameters

The launch token is passed as a `?token=...` URL parameter. This is the existing transport mechanism (currently used for the hex AccessGrant token) — we are only changing what's inside the parameter, not how it's delivered. JWTs in URLs have known trade-offs, but they don't apply meaningfully here:

- **Server logs / browser history** — the same exposure exists today with the hex tokens. The 3-minute expiry limits the window.
- **URL length** — JWTs are longer than the 32-char hex tokens (~200-300 chars for a simple HS256 JWT), but well within URL limits (~2000 chars).
- **Referer header leakage** — all three active runtimes strip the token from the URL after extracting it (per the research doc).
- **Token lifetime** — the runtime immediately exchanges the launch token for a longer-lived JWT via `api/v1/jwt/portal` or `api/v1/jwt/firebase`. The launch token is used once and expires in 3 minutes.

The security properties are arguably better than the current hex tokens: JWTs are cryptographically signed (can't be forged) and carry their own expiration (can't be replayed after expiry without a database check).

## Testing

- Unit tests for `check_for_auth_token`: JWT-as-Bearer routing, existing AccessGrant path still works.
- Update `external_activity` and `create_collaboration` specs to expect JWTs.
- Integration: verify jwt/portal and jwt/firebase endpoints work when the initial Bearer token is a JWT.
