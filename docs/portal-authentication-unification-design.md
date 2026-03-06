# Portal API Authentication — Current State & Unification Options

**Date:** 2026-02-25 (updated 2026-03-05)
**Status:** Draft / Discussion

## Overview

While designing the OIDC authentication strategy (see `specs/2026-02-25-portal-oidc-authentication-design.md`), we identified an "overlap problem" between Devise's `current_user` and the manual `check_for_auth_token` method in `API::APIController`. Investigation revealed the problem is deeper than initially described in Section 4 of that document.

The Portal's API authentication has two parallel systems that evolved independently:

1. **Devise/Warden strategies** — Standard Rails authentication that sets `current_user`
2. **`check_for_auth_token`** — A manual method in `API::APIController` that parses the `Authorization` header independently

These two systems overlap in some cases and diverge in others. After recent simplifications (removing peer-to-peer auth and client-less grants — see Sections 2.1 and 2.2), they now agree on **user identity** for all token types, but diverge on **role context** (see Section 3) and **OIDC compatibility** (see Section 4). This document maps the full landscape and discusses options for further improvement.

### Scope

This document is scoped to the Portal itself. All existing external applications must continue to work. An external application that hasn't made a request to the Portal in 24+ months can be considered inactive and doesn't need to be supported. When necessary, logs can be searched to verify activity.

---

## 1. Current Authentication Paths

### 1.1 Devise/Warden Strategies

Devise tries strategies in declaration order (see `app/models/user.rb`). Each strategy inspects the request and either authenticates or passes to the next.

**`BearerTokenAuthenticatable`** (`lib/bearer_token_authenticatable.rb`)
- Matches: `Authorization: Bearer <token>`
- Looks up `AccessGrant.find_by_access_token(token)`
- **Requires** `grant.client` to be present
- **Requires** the request referer to match `grant.client.domain_matchers` (see Section 5)
- Sets `current_user` to `grant.user`

**`JwtBearerTokenAuthenticatable`** (`lib/jwt_bearer_token_authenticatable.rb`)
- Matches: `Authorization: Bearer/JWT <token>` or `Authorization: Bearer <jwt-with-dots>` when `SignedJwt.portal_token?` returns true (checks unverified `iss` matches `APP_CONFIG[:site_url]`, or for legacy tokens, `uid` present without `iss`)
- Decodes token via `JWT.decode` with the portal's HMAC secret
- Extracts `uid` claim, sets `current_user` to `User.find_by_id(uid)`
- Does **not** extract role claims (learner_id, teacher_id, user_type)
- Uses halting `fail!` with distinct messages: `:token_expired` for expired tokens, `:invalid_token` for signature failures or missing user — since `valid?` guarantees the token is ours, all failures are definitive

**Session-based** (Devise's built-in `database_authenticatable`)
- Standard cookie/session authentication
- Sets `current_user` from the session

### 1.2 `check_for_auth_token` (`app/controllers/api/api_controller.rb:26-84`)

A manual method that parses the `Authorization` header and returns a `[user, role]` tuple. It extracts the token via `extract_bearer_token`, then routes based on token type using the same `SignedJwt.portal_token?` check as the Devise strategies:

**Case 1: Portal JWT** (lines 31-47)
- Matches: `Authorization: Bearer/JWT <token>` **or** `Authorization: Bearer <token>` when `SignedJwt.portal_token?` returns true (checks unverified `iss` matches the portal, or legacy tokens with `uid` but no `iss`)
- Decodes JWT and extracts role claims:
  ```ruby
  role = {
    :learner => data["user_type"] == "learner" ? Portal::Learner.find_by_id(data["learner_id"]) : nil,
    :teacher => data["user_type"] == "teacher" ? Portal::Teacher.find_by_id(data["teacher_id"]) : nil
  }
  ```
- Returns: `[User.find(data["uid"]), role]`
- This is now the **primary** auth path for launch tokens (see Section 2.1)

**Case 2: Non-portal JWT** (lines 48-55)
- Matches: JWT-shaped tokens (contains dots or `Bearer/JWT` scheme) where `SignedJwt.portal_token?` returns false (e.g., OIDC tokens)
- Falls through to `current_user` (already authenticated by the OIDC Devise strategy)
- Returns: `[current_user, nil]` (role is nil — OIDC callers use parameter-based role resolution)

**Case 3: AccessGrant Bearer token** (lines 57-72)
- Matches: `Authorization: Bearer <token>` where the token is not a JWT (no dots)
- Looks up `AccessGrant.find_by_access_token(token)`
- Returns: `[grant.user, {:learner => grant.learner, :teacher => grant.teacher}]`
- **Does not** check for a client or validate the referer
- Used for client-backed grants from OAuth flows (e.g., report launches)

**Case 4: Session fallback** (lines 78-83)
- When no Authorization header matches, falls back to `current_user`
- Returns: `[current_user, nil]` (role is nil)

> **History:** Prior to 2026-02-27, this method had two additional cases for peer-to-peer authentication (Cases B and C in the original document). These were removed after research confirmed no production traffic used them. See `specs/2026-02-26-peer-to-peer-auth-removal-research.md` for details.

### 1.3 Wrapper Helpers

`API::APIController` also provides two helpers built on `check_for_auth_token`:

- **`auth_not_anonymous(params)`** (lines 103-115) — Calls `check_for_auth_token`, rejects anonymous users. Returns `{user:, role:}` hash.
- **`auth_teacher(params)`** (lines 117-127) — Calls `auth_not_anonymous`, then checks `user.portal_teacher` (database lookup, not the role from the token).

---

## 2. The User Identity Gap

For all current token types, `check_for_auth_token` and Devise's `current_user` agree on user identity:

| Scenario | Devise `current_user` | `check_for_auth_token` user | Match? |
|---|---|---|---|
| AccessGrant **with** client | `grant.user` | `grant.user` | Yes |
| Portal JWT (Bearer/JWT or Bearer with dots) | `User.find(uid)` | `User.find(uid)` | Yes |
| Session fallback | `current_user` | `current_user` | Yes |

The remaining divergence is **role context**, not user identity — see Section 3.

### 2.1 Client-less AccessGrants (Resolved)

**Status: Eliminated.** The two creation sites that produced client-less AccessGrants (`external_activity.rb` and `create_collaboration.rb`) now mint short-lived Portal JWTs via `SignedJwt::create_portal_token` instead. The `User#create_access_token_with_learner_valid_for` method has been removed. See `specs/2026-02-26-clientless-grants-jwt-replacement-design.md` for the full design and `specs/2026-02-26-clientless-grants-replacement-research.md` for the runtime compatibility research.

The `check_for_auth_token` method was updated to route `Bearer <token>` to JWT decoding when the token contains dots (JWTs always have dots; hex AccessGrant tokens never do). This means launch tokens now flow through Case 1 (JWT) rather than Case 2 (AccessGrant).

Client-backed AccessGrants (created by OAuth clients via `Client#updated_grant_for`) are unaffected — they still flow through the Devise bearer strategy and Case 2 of `check_for_auth_token`.

**Note on current inconsistency:** This stepping stone means resource launches (ExternalActivity, collaborations) now use JWTs while report launches (ExternalReport) still use client-backed AccessGrants. The two launch paths use different token types, different Devise strategies, and different cases in `check_for_auth_token`. This is a temporary inconsistency — both paths are planned to converge on OAuth2 implicit flow (see Next Steps, Steps 3-5), at which point neither will use portal-minted launch tokens.

### 2.2 Peer-to-peer Authentication (Resolved)

**Status: Removed from `check_for_auth_token`.** Research confirmed zero production traffic used the peer-to-peer code path (Cases B and C in the original method). See `specs/2026-02-26-peer-to-peer-auth-removal-research.md` for the full investigation, including GitHub org search, production client cross-reference, and 365-day log analysis.

**Note:** The `request_is_peer?` policy check in `CollaborationPolicy#collaborators_data?` remains active — it is used by the report-service's `auto-importer` Cloud Function (~1,092 requests/year). This is independent of `check_for_auth_token` and was not affected by the removal.

---

## 3. The Role Context Gap

### What role information is

The `role` in the `[user, role]` tuple is a hash: `{:learner => Portal::Learner|nil, :teacher => Portal::Teacher|nil}`. It represents the user's **active context** for this session — which specific learner or teacher record they're operating as.

A single user can be both a student and a teacher, and can be a student in multiple classes (each with a different `Portal::Learner` record). The role says "for this request, the user is acting as learner #456 in offering #789."

### Where role information originates

Role is either embedded at token-creation time or resolved from parameters:

1. **Launch JWT path:** When the Portal launches an external activity or creates a collaboration, it mints a short-lived JWT with role claims: `SignedJwt::create_portal_token(user, {learner_id: learner.id, user_type: "learner"}, 180)`. The runtime exchanges this for a longer-lived JWT via `JwtController`. This path is planned for replacement with OAuth2 launches (see Next Steps, Step 3), which would use parameter-based role resolution instead of token-embedded role.

2. **Report launch AccessGrant path:** When an ExternalReport is launched for a teacher, `grant.teacher` is set; for a student, `grant.learner` is set (see the report Authorization section in `docs/external-services.md`). These are client-backed grants (created via `Client#updated_grant_for`). The behavior after launch varies by report: the CLUE dashboard exchanges its AccessGrant token for a Portal JWT (like resource launches do), while portal-report uses the AccessGrant token directly for all Portal API calls without exchanging it. Once launch JWTs are replaced with OAuth2 (Next Steps, Step 3), this would be the only remaining source of token-embedded role. Report launches could also be migrated to use OAuth2 with parameter-based role in the future, but that is out of scope for this document.

3. **OAuth2 implicit grant path:** When an SPA authenticates via the OAuth2 implicit grant flow (see the OAuth2 Authorization section in `docs/external-services.md`), the resulting AccessGrant has no learner or teacher set — it carries only user identity. Role must be resolved from URL parameters (e.g., `resource_link_id`) when the SPA requests a JWT from `JwtController`. This is the pattern we want all launch paths to converge on (see Next Steps, Step 3).

4. **JwtController minting path:** When `JwtController` mints a Portal JWT, it includes `user_type`, `learner_id`, and `teacher_id` claims based on the role from the incoming token (or from parameter-based overrides like `resource_link_id` and `as_learner`).

### The Devise strategies don't extract role

Neither Devise strategy extracts role information. `BearerTokenAuthenticatable` finds `grant.user` but ignores `grant.learner`/`grant.teacher`. `JwtBearerTokenAuthenticatable` decodes the JWT but only reads `uid`, ignoring `user_type`/`learner_id`/`teacher_id`.

This is the core tension: Devise handles authentication (who are you?) but not authorization context (what role are you acting as?). `check_for_auth_token` does both in one step.

### Which controllers actually use the role?

We audited every caller of `check_for_auth_token`:

| Controller | Calls | Uses `role`? | How it determines role instead |
|---|---|---|---|
| `BookmarksController` | ~~`check_for_auth_token` via `check_auth`~~ **Migrated to `current_user`** | **No** | `current_user.portal_teacher` (database) |
| `TeacherClassesController` | ~~`check_for_auth_token` via `auth_teacher`~~ **Migrated to `current_user`** | **No** | `current_user.portal_teacher` (database) |
| `ExternalActivitiesController` | ~~`check_for_auth_token` directly~~ **Migrated to `current_user`** | **No** | Only uses `current_user` for ownership |
| `OfferingsController` | ~~`check_for_auth_token` directly~~ **Migrated to `current_user`** | **No** | `clazz.is_teacher?(current_user)` (database) |
| **`JwtController`** | `check_for_auth_token` via `handle_initial_auth` | **Yes** | Needs learner/teacher to mint new JWTs with role claims |

Only `JwtController` genuinely needs the token-embedded role. The other four controllers have been migrated to use `current_user` directly (see `specs/2026-03-04-controller-migration-design.md`).

Note: even `auth_teacher` — which sounds role-related — checks `user.portal_teacher` (a database lookup), not the `:teacher` value from the role hash.

### Controllers that already use `current_user` + Pundit

These controllers demonstrate the "newer" pattern that works with any Devise strategy, including the planned OIDC strategy:

- `ClassesController` — `current_user.portal_teacher`, `current_user.portal_student`, Pundit `authorize`
- `StudentsController` — Pundit `authorize portal_clazz, :update_roster?`
- `ReportUsersController` — Pundit authorization

---

## 4. The JwtController Challenge

`JwtController` deserves special attention because it's the only endpoint where the token-embedded role genuinely matters — and it's also the most complex auth consumer in the codebase.

### What `handle_initial_auth` does (lines 86-140)

1. Calls `check_for_auth_token(params)` to get `[user, role]`
2. Unpacks role into `learner` and `teacher`
3. If `resource_link_id` param is present, **overrides** the token-derived role:
   - Student user → looks up learner from the offering
   - Teacher user → sets teacher from `user.portal_teacher`
   - Other user (admin/researcher) → clears learner/teacher, validates `target_user_id` permissions
4. Returns `[user, learner, teacher]`

### The parameter-based override already exists

The `resource_link_id`, `as_learner`, `as_teacher`, and `as_user` parameters (lines 152-171) already provide a way to specify role context **without** relying on the token's embedded role. The token role serves as a default that gets overridden in many cases.

There is also a FIXME at line 94 noting an existing inconsistency:

```ruby
# FIXME: there is inconsiency here
# When the user is a teacher, but the auth token (grant) doesn't have the teacher set,
# the returned teacher here will be nil, unless a valid resource_link_id is passed in.
```

This suggests the token-embedded role is already unreliable and the parameter-based path is the more robust mechanism.

### OIDC and JwtController

The OIDC caller (the button interactive's Cloud Function) may need to call JwtController to get a Firebase token for the teacher of a specific student and class. In this scenario:

- The OIDC token carries no learner/teacher role (only user identity via the service account mapping)
- `check_for_auth_token` would fall through to the session fallback, returning `[current_user, nil]`
- The Cloud Function would need to use parameter-based role resolution (`resource_link_id`, `target_user_id`, etc.)
- `handle_initial_auth` already supports this path (lines 115-136: "This case is really for only for firebase JWTs")

So JwtController should work with OIDC **if** the caller provides the right params. The main issue is how `check_for_auth_token` handles the `Authorization: Bearer <oidc-token>` header.

**Resolved.** `check_for_auth_token` now uses `SignedJwt.portal_token?` to explicitly identify portal JWTs before attempting to decode them. Non-portal JWTs (e.g., OIDC tokens) are routed to a separate branch that falls through to `current_user` (already set by the Devise strategy). This avoids the need for try/catch-based routing and uses the same shared detection logic as the Devise strategies.

---

## 5. The Referer Check

The referer check in the Devise bearer strategy (`grant.client.valid_from_referer?`) and OAuth redirect validation are sometimes confused because both involve Client configuration and URL validation. They are **separate mechanisms** that serve different purposes:

### Referer check (`domain_matchers`)

- **When:** During bearer token authentication (every request with `Authorization: Bearer <token>`)
- **What:** Validates the `HTTP_REFERER` header against `Client.domain_matchers` (regex patterns)
- **Purpose:** Ensures a bearer token is only used from the expected origin (e.g., the SPA that was launched)
- **Optional:** If `domain_matchers` is blank, any referer is accepted
- **Example:** `domain_matchers: "portal-report.concord.org"` — token can only be used from requests originating from that domain

### OAuth redirect validation (`redirect_uris`)

- **When:** During OAuth2 authorization flow only (`/auth/oauth_authorize`)
- **What:** Validates the `redirect_uri` parameter against `Client.redirect_uris` (exact string match)
- **Purpose:** Controls where the Portal sends the user (and auth token/code) after sign-in
- **Example:** `redirect_uris: "https://portal-report.concord.org/branch/master/index.html"` — after OAuth, redirect only to that URL

### How they interact

A Client can have both configured. The Portal Report SPA is a good example:

```ruby
Client.create(
  name: "Portal Report SPA",
  domain_matchers: "portal-report.concord.org",     # Bearer token referer check
  redirect_uris: "https://portal-report.concord.org/branch/master/index.html"  # OAuth redirect
)
```

When launched from the Portal, the SPA receives a bearer token and the referer check validates requests. When the SPA is used standalone (not launched from the Portal), it does an OAuth flow and the redirect validation controls the callback.

### Relevance to unification

The referer check is **only applied by the Devise bearer strategy**, not by `check_for_auth_token`. This means:
- Client-backed grants authenticated via Devise get referer validation
- The same grants authenticated via `check_for_auth_token` do **not** get referer validation

Launch tokens are now JWTs (not AccessGrants), so they bypass the Devise bearer strategy entirely — the referer check is not relevant for them. If we unify authentication into Devise for the remaining AccessGrant paths, we'd need to decide whether to enforce referer checks on currently-unchecked paths.

**Research conclusion (see `specs/2026-03-02-referer-validation-research.md`):** This is **not a concern for Step 1**. Investigation of the four controllers being migrated found that none of their callers are affected by the referer check:
- `BookmarksController` and `TeacherClassesController` are called only by the Portal's own React frontend using session cookies (no Bearer token involved)
- `ExternalActivitiesController` is called only by LARA, whose Clients (IDs 2, 3, 4) have blank `domain_matchers` — the referer check is a no-op
- `OfferingsController`'s `create_for_external_activity` is called only by CLUE Standalone, which sends a Portal JWT via `Bearer/JWT` (not an AccessGrant) — the referer check is never reached

Of 25 production Clients, 10 enforce referer checks — but all 10 are report/dashboard SPAs whose tokens are used on endpoints that already authenticate via `current_user` or that remain on `check_for_auth_token` (JwtController).

---

## 6. Further Unification

### What's been done

**Client-less grants replaced with JWTs (original Option B).** See `specs/2026-02-26-clientless-grants-jwt-replacement-design.md` for the design. The key changes:
- `external_activity.rb` and `create_collaboration.rb` now mint JWTs via `SignedJwt::create_portal_token` instead of creating client-less AccessGrants
- `check_for_auth_token` routes `Bearer <token-with-dots>` to JWT decoding before attempting AccessGrant lookup
- `User#create_access_token_with_learner_valid_for` has been removed

**Peer-to-peer auth (Cases B/C) removed from `check_for_auth_token`.** See `specs/2026-02-26-peer-to-peer-auth-removal-research.md` for the research that confirmed zero production traffic.

### What remains

With all four non-role controllers migrated, `JwtController` is the sole consumer of `check_for_auth_token`. One step remains for full OIDC compatibility:

1. **Add OIDC fallback to `check_for_auth_token` for JwtController** — it still needs role extraction from the token, but must handle unrecognized JWTs gracefully. Token-embedded role is a deprecated pattern; clients should migrate to parameter-based role resolution over time.

### Step 1: Migrate controllers off `check_for_auth_token` — COMPLETED

The four controllers that used `check_for_auth_token` only for authentication (not role) have been migrated to use `current_user` instead. Each controller's existing authorization logic was preserved as-is.

The original design proposed Devise's `authenticate_user!`, but implementation used a custom `require_api_user!` guard instead because `CustomFailure` redirects HTML-format requests. The custom guard uses the existing `error()` JSON pattern for consistency. See `specs/2026-03-04-controller-migration-design.md` for details.

| Controller | Previous auth | Current auth |
|---|---|---|
| `BookmarksController` | `check_for_auth_token` via `check_auth` | `require_api_user!` + `current_user` + `authorize_class_teacher!` |
| `TeacherClassesController` | `check_for_auth_token` via `auth_teacher` | `require_api_user!` + `require_teacher!` + `current_user` + existing class ownership helpers |
| `ExternalActivitiesController` | `check_for_auth_token` directly | `require_api_user!` + `current_user` + existing Pundit policies |
| `OfferingsController` | `check_for_auth_token` directly | `current_user` + existing Pundit policies / `is_teacher?` (no `require_api_user!` — Pundit handles guest rejection) |

**Status: Completed.** All four controllers have been migrated. See `specs/2026-03-04-controller-migration-design.md` for implementation details and PR #1469. These controllers now automatically work with OIDC (and any future Devise strategy) without any changes to `check_for_auth_token`. Converting `BookmarksController` and `TeacherClassesController` to Pundit can be a separate step later if desired.

### Step 2: JwtController — keep `check_for_auth_token` as a deprecated role source

Once the other controllers are migrated, `JwtController` is the sole consumer of `check_for_auth_token`. Its `handle_initial_auth` method needs two things: (1) the authenticated user, and (2) the role context (learner/teacher) from the token. Today `check_for_auth_token` provides both in one call.

#### Why not eliminate the double token parsing now?

It's tempting to eliminate the duplicated token parsing (Devise parses the token for user identity, then `check_for_auth_token` parses it again for role). Two approaches were considered:

- **Separate `role_from_auth_token` method** — parses the Authorization header a second time but only extracts role. Simple but duplicates work.
- **Cache auth credentials in Devise `env`** — strategies store the raw grant or decoded JWT in `request.env`, then a helper reads role from the cached credential. No duplication, but requires updating the Devise strategies — and the `jwt_bearer_token_authenticatable` strategy would need dot-detection to handle JWT launch tokens (currently these are **not authenticated by Devise at all** since the JWT strategy only matches `Bearer/JWT`, not `Bearer <token-with-dots>`).

Both approaches also raise a design concern: **token-embedded role is a pattern we want to discourage, not formalize.** Extracting role from the token (whether via JWT claims or AccessGrant associations) makes the code harder to reason about. The preferred direction is for clients to send role context as URL parameters (`resource_link_id`, `as_learner`, etc.) — `handle_initial_auth` already supports this and it's the more robust mechanism (see the FIXME at line 94). Investing in a clean role extraction architecture means polishing a pattern we want to phase out.

#### Recommendation: accept the double parsing temporarily

Keep `check_for_auth_token` as the sole method for JwtController, renamed to make its temporary nature clear. The method name and comments should signal that token-embedded role is deprecated and clients should migrate to parameter-based role resolution.

The double parsing is a minor cost:
- For JWTs, `SignedJwt::decode_portal_token` is fast crypto work (microseconds)
- For AccessGrants, it's one extra indexed DB query
- Both only happen on JwtController requests, not the four migrated controllers

When all launches use OAuth2 with parameter-based role resolution (see Next Steps, Step 5), the method can be deleted entirely — and the double parsing goes away with it. There's no point optimizing throwaway code.

#### What OIDC compatibility requires — COMPLETED

`check_for_auth_token` now uses `SignedJwt.portal_token?` — the same shared method used by the Devise JWT strategy — to explicitly identify portal JWTs before attempting decode. Non-portal JWTs (OIDC, etc.) are routed to a separate branch that falls through to `current_user`:

```ruby
token = extract_bearer_token(header)

if token && (header =~ /^Bearer\/JWT/i || SignedJwt.probably_jwt?(token))
  if SignedJwt.portal_token?(token)
    # Portal JWT — decode and extract user + role
    decoded_token = SignedJwt::decode_portal_token(token)
    # ...
  else
    # Non-portal JWT (e.g., OIDC) — already authenticated by Devise
    return [current_user, nil] if current_user
    raise StandardError, 'You must be logged in to use this endpoint'
  end
elsif token
  # Not a JWT — opaque AccessGrant token
  # ...
```

The nil role is fine — `handle_initial_auth` already handles nil role via parameter-based resolution (`resource_link_id`, `target_user_id`, etc.). OIDC callers would need to provide these parameters, which is the direction we want to move all callers toward anyway.

---

## 7. Discussion Questions

1. ~~**Client-less grants — can we eliminate them?**~~ **Resolved.** Replaced with JWTs. See `specs/2026-02-26-clientless-grants-jwt-replacement-design.md`.

2. ~~**Peer-to-peer auth — is it actively used?**~~ **Resolved.** No production traffic used the `check_for_auth_token` peer-to-peer path. Cases B and C have been removed. The `request_is_peer?` policy check for `collaborators_data` remains (active report-service traffic). See `specs/2026-02-26-peer-to-peer-auth-removal-research.md`.

3. ~~**OIDC + JwtController — is it needed for the button interactive?**~~ **Yes.** OIDC callers will need to create JWTs. The unification steps in Section 6 (migrate controllers to `current_user`, then separate role extraction from authentication in JwtController) will enable this.

4. ~~**Referer validation — what would break?**~~ **Resolved.** Nothing would break for Step 1. Research confirmed that none of the four migrated controllers' callers are affected: two use session cookies (no Bearer token), one caller's Clients have blank `domain_matchers` (referer check is a no-op), and one caller uses Portal JWTs (bypasses the referer check entirely). See `specs/2026-03-02-referer-validation-research.md`.

5. ~~**Role extraction approach — which is better?**~~ **Resolved.** Accept the double token parsing temporarily. Token-embedded role is a pattern we want to deprecate, not formalize. `check_for_auth_token` stays as JwtController's sole auth method until clients migrate to parameter-based role resolution, at which point the method is deleted. See Section 6 Step 2.

---

## 8. Auth Failure Error Responses

### The inconsistency

The two auth paths produce different error responses when authentication fails:

**`check_for_auth_token` path** (used by `JwtController`): Token failures raise exceptions (`SignedJwt::Error`, `StandardError`), and `JwtController`'s `rescue_from` renders the exception message directly. Clients see specific error messages like `"Signature has expired"` or `"AccessGrant has expired"`.

**Devise strategy path** (used by all other API controllers via `current_user`): When a strategy calls `fail!(:token_expired)` or `fail!(:invalid_token)`, Warden stores the message symbol internally. But `CustomFailure` (the Warden failure app, `lib/custom_failure.rb`) does not surface these symbols in JSON responses — it only uses them for redirect decisions and logging. For API requests, the client receives a generic 401 with no body indicating the failure reason. For Pundit-protected endpoints, the response is a generic 403.

This means:
- **`JwtController` endpoints**: Clients see specific error reasons (expired, invalid signature, user not found, etc.)
- **All other API endpoints**: Clients see only a generic 401/403 with no information about _why_ authentication failed

### Impact

For debugging and client-side error handling, clients cannot distinguish between an expired token (which should trigger a refresh) and an invalid token (which indicates a configuration or security problem). The Devise strategies now store this distinction internally (`:token_expired` vs `:invalid_token`), but it doesn't reach the HTTP response.

---

## 9. Completed Work and Next Steps

### Completed

1. **Peer-to-peer auth removed from `check_for_auth_token`.** Research confirmed zero production traffic. Cases B and C deleted. See `specs/2026-02-26-peer-to-peer-auth-removal-research.md`.

2. **Client-less grants replaced with JWTs.** Both creation sites (`external_activity.rb`, `create_collaboration.rb`) now mint Portal JWTs. `check_for_auth_token` routes `Bearer <token-with-dots>` to JWT decoding. `User#create_access_token_with_learner_valid_for` removed. See `specs/2026-02-26-clientless-grants-jwt-replacement-design.md`.

3. **`check_for_auth_token` simplified** from 5 cases to 3: JWT (with dot detection) → AccessGrant → session fallback.

4. **Referer validation researched for Step 1.** Confirmed that none of the four controllers' callers are affected by the Devise bearer strategy's referer check. See `specs/2026-03-02-referer-validation-research.md`.

5. **Four controllers migrated to `current_user`** (Section 6 Step 1). All four controllers (`BookmarksController`, `TeacherClassesController`, `ExternalActivitiesController`, `OfferingsController`) now use `current_user` instead of `check_for_auth_token`. A custom `require_api_user!` guard in `API::APIController` returns JSON 401 for unauthenticated requests (Devise's `authenticate_user!` was not used because `CustomFailure` redirects HTML-format requests instead of returning JSON). `JwtController` is now the sole consumer of `check_for_auth_token`. See `specs/2026-03-04-controller-migration-design.md` and PR #1469.

6. **Issuer-based strategy routing and distinct error messages.** Portal JWTs now include an `iss: APP_CONFIG[:site_url]` claim. The portal token detection logic is extracted into `SignedJwt.portal_token?`, a shared method used by both the JWT Devise strategy's `valid?` and `check_for_auth_token`. The OIDC strategy checks for Google issuers. The JWT strategy uses halting `fail!` with distinct messages (`:token_expired` vs `:invalid_token`) since `valid?` guarantees the token is ours.

7. **OIDC fallback in `check_for_auth_token` — COMPLETED.** `check_for_auth_token` now uses `SignedJwt.portal_token?` to explicitly route portal JWTs vs non-portal JWTs (e.g., OIDC). Non-portal JWTs fall through to `current_user` (already set by the Devise strategy) instead of failing at `SignedJwt::decode_portal_token`. This unblocks OIDC callers for JwtController.

### Next steps

1. ~~**Migrate four controllers to `current_user`**~~ **Done.** See Completed item 5 above.

2. ~~**Add OIDC fallback to `check_for_auth_token`**~~ **Done.** See Completed item 7 above.

3. **Add OAuth2 launch support to ExternalActivities.** Add a new launch option in the ExternalActivity settings as an alternative to the current "auth token" approach. Instead of minting a short-lived JWT and passing it as a `token` parameter, the Portal would generate a launch URL with a standard set of OAuth2 initialization parameters (auth domain, resource link ID, class/offering context, etc.). The SPA handles authentication via the OAuth2 implicit grant redirect on first load — see the "SPA OAuth2 initialization pattern" in `docs/external-services.md` for the existing client-side pattern. The exact parameter naming convention (camelCase, kebab-case, or snake_case) can be decided at implementation time. The Portal does not need to know the SPA's OAuth2 Client — each SPA already hardcodes its own `client_id` (e.g., CLUE uses `"clue"`, portal-report uses `"portal-report"`) and initiates the OAuth2 redirect itself.

4. **Update clients to support standard OAuth2 launch parameters.** Update external runtimes (CLUE, Activity Player, etc.) to support the standardized parameter names defined in step 3, and switch their ExternalActivity configurations in the Portal to use the new OAuth2 launch option. CLUE and Activity Player already support OAuth2 initialization parameters (see `docs/external-services.md`), so this is primarily a matter of aligning on the standard names.

5. **Remove single-use token launching.** Once all ExternalActivities are migrated to OAuth2 launches, remove the short-lived JWT launch path from `external_activity.rb` and `create_collaboration.rb`. At this point `check_for_auth_token`'s JWT case is only needed for JwtController's own token refresh, and the method can potentially be eliminated entirely if role is fully resolved via parameters.

6. **Unified JSON error responses for API auth failures** (see Section 8). Surface the Warden failure reason (`:token_expired`, `:invalid_token`, etc.) in the JSON response for API requests, so all API endpoints return consistent, informative error messages. Two possible approaches:
   - Update `CustomFailure` to return a JSON body with the failure symbol for API-format requests (e.g., `{ "error": "token_expired" }`)
   - Add a `before_action` in `API::APIController` that checks `warden.message` after failed authentication and renders a JSON error before Pundit runs
