# Portal API Authentication — Current State & Unification Options

**Date:** 2026-02-25
**Status:** Draft / Discussion

## Overview

While designing the OIDC authentication strategy (see `portal-oidc-authentication-design.md`), we identified an "overlap problem" between Devise's `current_user` and the manual `check_for_auth_token` method in `API::APIController`. Investigation revealed the problem is deeper than initially described in Section 4 of that document.

The Portal's API authentication has two parallel systems that evolved independently:

1. **Devise/Warden strategies** — Standard Rails authentication that sets `current_user`
2. **`check_for_auth_token`** — A manual method in `API::APIController` that parses the `Authorization` header independently

These two systems overlap in some cases, diverge in others, and produce different results for the same request in certain scenarios. This document maps the full landscape and discusses options for improvement.

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
- Matches: `Authorization: Bearer/JWT <token>`
- Decodes token via `SignedJwt::decode_portal_token`
- Extracts `uid` claim, sets `current_user` to `User.find_by_id(uid)`
- Does **not** extract role claims (learner_id, teacher_id, user_type)

**Session-based** (Devise's built-in `database_authenticatable`)
- Standard cookie/session authentication
- Sets `current_user` from the session

### 1.2 `check_for_auth_token` (`app/controllers/api/api_controller.rb:26-97`)

A manual method that parses the `Authorization` header and returns a `[user, role]` tuple. It handles four cases:

**Case A: AccessGrant Bearer token** (line 28-37)
- Matches: `Authorization: Bearer <token>` where `AccessGrant.find_by_access_token(token)` exists
- Returns: `[grant.user, {:learner => grant.learner, :teacher => grant.teacher}]`
- **Does not** check for a client or validate the referer

**Case B: Peer-to-peer — learner context** (lines 40-54)
- Matches: `Authorization: Bearer <token>` where the token is a `Client.app_secret` and `params[:learner_id_or_key]` is present
- Returns: `[learner.student.user, {:learner => learner, :teacher => nil}]`
- The returned user comes from the **learner param**, not from the token

**Case C: Peer-to-peer — user context** (lines 56-68)
- Matches: `Authorization: Bearer <token>` where the token is a `Client.app_secret` and `params[:user_id]` is present
- Returns: `[User.find(params[:user_id]), {:learner => nil, :teacher => nil}]`
- The returned user comes from the **user_id param**, not from the token

**Case D: Portal JWT** (lines 74-91)
- Matches: `Authorization: Bearer/JWT <token>`
- Decodes JWT and extracts role claims:
  ```ruby
  role = {
    :learner => data["user_type"] == "learner" ? Portal::Learner.find_by_id(data["learner_id"]) : nil,
    :teacher => data["user_type"] == "teacher" ? Portal::Teacher.find_by_id(data["teacher_id"]) : nil
  }
  ```
- Returns: `[User.find(data["uid"]), role]`

**Case E: Session fallback** (lines 92-96)
- When no Authorization header matches, falls back to `current_user`
- Returns: `[current_user, nil]` (role is nil)

### 1.3 Wrapper Helpers

`API::APIController` also provides two helpers built on `check_for_auth_token`:

- **`auth_not_anonymous(params)`** (lines 135-147) — Calls `check_for_auth_token`, rejects anonymous users. Returns `{user:, role:}` hash.
- **`auth_teacher(params)`** (lines 149-159) — Calls `auth_not_anonymous`, then checks `user.portal_teacher` (database lookup, not the role from the token).

---

## 2. The User Identity Gap

In two scenarios, `check_for_auth_token` returns a **different user** than Devise's `current_user` would be for the same request:

| Scenario | Devise `current_user` | `check_for_auth_token` user | Match? |
|---|---|---|---|
| AccessGrant **with** client | `grant.user` | `grant.user` | Yes |
| AccessGrant **without** client | nil (Devise rejects — no client) | `grant.user` | **No** |
| Peer-to-peer (learner_id_or_key) | nil (Devise rejects — no AccessGrant) | `learner.student.user` | **No** |
| Peer-to-peer (user_id) | nil (Devise rejects — no AccessGrant) | `User.find(params[:user_id])` | **No** |
| Bearer/JWT | `User.find(uid)` | `User.find(uid)` | Yes |
| Session fallback | `current_user` | `current_user` | Yes |

### 2.1 Client-less AccessGrants

As documented in `docs/external-services.md` (lines 39-48), non-LARA runtime launches create short-lived AccessGrant tokens without an associated Client. These tokens are passed to the runtime as URL parameters during launch. The runtime sends them back via `Authorization: Bearer <token>` to call Portal APIs.

The Devise bearer strategy rejects these tokens because it requires `grant.client` (line 24 of `bearer_token_authenticatable.rb`). So these tokens can **only** be used with endpoints that call `check_for_auth_token` directly. The external-services doc notes: "this short lived token can only be used with endpoints that use the API Controller's authentication check."

**Where client-less grants are created (production code only):**

There are exactly two creation sites, both creating very short-lived (3-minute) tokens:

1. **`app/models/external_activity.rb:150`** — When `append_auth_token` is true, creates a 3-minute token with a learner for launching external activities:
   ```ruby
   token = learner.user.create_access_token_with_learner_valid_for(3.minutes, learner)
   ```

2. **`app/services/api/v1/create_collaboration.rb:82`** — Creates a 3-minute token with a learner for collaboration:
   ```ruby
   token = @owner_learner.user.create_access_token_with_learner_valid_for(3.minutes, @owner_learner)
   ```

Both call `User#create_access_token_with_learner_valid_for` (`app/models/user.rb:301-303`), which creates an AccessGrant with a `learner_id` but no `client_id`.

**Observation:** Because these are 3-minute tokens and the external-services doc recommends exchanging them for a Portal JWT immediately, these grants serve only as a bootstrap mechanism. They are not long-lived and are not used for sustained API access.

### 2.2 Peer-to-peer Authentication

Peer-to-peer authentication allows a trusted service (identified by its `Client.app_secret`) to make requests on behalf of a specific learner or user. The token is the client's shared secret, and the actual user identity comes from request parameters.

**History:** Added in two commits:
- `fa241dd34` (June 2018): "Added peer-to-peer api authentication" — for "LARA to proxy firebase api calls from javascript clients." Added the `learner_id_or_key` variant.
- `07a839e96` (August 2019): "Added user-based peer authentication" — added the `user_id` variant for non-learner contexts.

**Current usage:** Despite the commit messages mentioning LARA, LARA itself uses OAuth2 (not peer-to-peer) as documented in `docs/external-services.md` lines 51-54. Investigation found:
- No production clients specifically configured for peer-to-peer
- No integration tests in any API controller specs that pass `learner_id_or_key` or `user_id` params with a client secret
- Unit tests exist in `api_controller_spec.rb` but only test the mechanism in isolation

This pattern appears to have been added for a use case that either never materialized or was superseded by other approaches.

**Security note:** The peer-to-peer path does **not** check `domain_matchers` or validate the referer. It only calls `Client.find_by_app_secret(token)` — any Client's `app_secret` is sufficient, regardless of how that Client is otherwise configured. This means the peer-to-peer path has weaker access controls than the Devise bearer token strategy.

**Verification approach:** To confirm whether peer-to-peer auth is actively used before deprecating:

1. **GitHub organization search:** Search the `concord-consortium` org for `learner_id_or_key`. This parameter name is unique to the peer-to-peer auth path — no other system would use it accidentally. For the `user_id` variant, search for code that sends a Client's `app_secret` as a Bearer token (e.g., `app_secret` near `Authorization` or `Bearer`).

2. **Cross-reference with production clients:** There are ~25 Clients configured on the production Portal. For each Client, check whether the owning application's codebase contains code that uses the `app_secret` for peer-to-peer requests (as opposed to OAuth2 flows, where `app_secret` is used differently — in the token exchange request body, not as a Bearer token).

3. **Request log analysis (if needed):** Rails logs include request parameters. Search for requests containing `learner_id_or_key` as a parameter. This is more reliable than searching for tokens in headers (which are not logged and should not be). For the `user_id` variant, the parameter name is too generic to search globally, but it can be narrowed by filtering to the specific controller paths that use `check_for_auth_token`:
   - `/api/v1/jwt/*`
   - `/api/v1/bookmarks/*`
   - `/api/v1/external_activities/*`
   - `/api/v1/offerings/*`
   - `/api/v1/teacher_classes/*`

   A `user_id` param on any other endpoint is unrelated to peer-to-peer auth. Filtering to these 5 paths should produce a small enough result set to inspect manually.

---

## 3. The Role Context Gap

### What role information is

The `role` in the `[user, role]` tuple is a hash: `{:learner => Portal::Learner|nil, :teacher => Portal::Teacher|nil}`. It represents the user's **active context** for this session — which specific learner or teacher record they're operating as.

A single user can be both a student and a teacher, and can be a student in multiple classes (each with a different `Portal::Learner` record). The role says "for this request, the user is acting as learner #456 in offering #789."

### Where role information originates

The role is embedded at token-creation time:

1. **AccessGrant path:** When the Portal creates a short-lived token for a runtime launch, it associates the grant with the relevant learner: `create_access_token_with_learner_valid_for`. When an ExternalReport is launched for a teacher, `grant.teacher` is set; for a student, `grant.learner` is set (`docs/external-services.md` lines 115-117).

2. **JWT path:** When `JwtController` mints a Portal JWT, it includes `user_type`, `learner_id`, and `teacher_id` claims based on the role from the original AccessGrant (or from parameter-based overrides like `resource_link_id` and `as_learner`).

### The Devise strategies don't extract role

Neither Devise strategy extracts role information. `BearerTokenAuthenticatable` finds `grant.user` but ignores `grant.learner`/`grant.teacher`. `JwtBearerTokenAuthenticatable` decodes the JWT but only reads `uid`, ignoring `user_type`/`learner_id`/`teacher_id`.

This is the core tension: Devise handles authentication (who are you?) but not authorization context (what role are you acting as?). `check_for_auth_token` does both in one step.

### Which controllers actually use the role?

We audited every caller of `check_for_auth_token`:

| Controller | Calls | Uses `role`? | How it determines role instead |
|---|---|---|---|
| `BookmarksController` | `check_for_auth_token` via `check_auth` | **No** | `user.portal_teacher` (database) |
| `TeacherClassesController` | `check_for_auth_token` via `auth_teacher` | **No** | `user.portal_teacher` (database) |
| `ExternalActivitiesController` | `check_for_auth_token` directly | **No** | Only uses `user` for ownership |
| `OfferingsController` | `check_for_auth_token` directly | **No** | `clazz.is_teacher?(user)` (database) |
| **`JwtController`** | `check_for_auth_token` via `handle_initial_auth` | **Yes** | Needs learner/teacher to mint new JWTs with role claims |

Only `JwtController` genuinely needs the token-embedded role. The other four controllers use `check_for_auth_token` as an **authentication mechanism** (to get the user), then derive role information from the database.

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

So JwtController should work with OIDC **if** the caller provides the right params. The main issue is that `check_for_auth_token` would try to parse the `Authorization: Bearer <oidc-token>` header as an AccessGrant first (and fail), before falling through to the session fallback where Devise has already set `current_user`. This is wasteful but functional — the OIDC token would be rejected as an AccessGrant, the peer-to-peer checks would fail, and then the session fallback would find `current_user` already set by the OIDC Devise strategy.

Actually, this wouldn't work cleanly. The `check_for_auth_token` method checks `Bearer` format first (line 28), and if the token isn't a valid AccessGrant and no peer params are present, it **raises an exception** at line 71: `"Cannot find AccessGrant for requested token"`. It never reaches the session fallback. So OIDC-authenticated requests to JwtController would fail.

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
- Client-less grants bypass both (no client → no domain_matchers → no check)

If we unify authentication into Devise, we'd need to decide whether to enforce referer checks on currently-unchecked paths. This could break external services that don't send referer headers.

---

## 6. Options for Improvement

### Option A: Eliminate Client-less Grants, Unify Into Devise

**Idea:** Fix the two creation sites that produce client-less grants so they include a client. Then Devise can authenticate all AccessGrant tokens uniformly, and `check_for_auth_token` loses its primary reason to exist.

**For external_activity.rb launch tokens:** Associate the launch token with a Client. The `docs/external-services.md` (Section "Provide Clients for ExternalActivities") proposes connecting Tools to Clients, but this connection doesn't exist yet — the Tool model has no `client_id` field. To use the Tool→Client approach:

1. Add a `client_id` foreign key to the Tool model
2. Assign Tools to ExternalActivities that don't already have one (~10 unique Tools for a few thousand resources)
3. Configure each Tool's Client with appropriate `domain_matchers` for the SPA's domain

**Tool assignment side effects:** Adding a Tool to an ExternalActivity is safe as long as the Tool's `source_type` is `nil`. The key behaviors gated by Tool are:
- `lara_activity_or_sequence?` — only returns `true` for `source_type == 'LARA'`, so `nil` is safe
- `DefaultReportService.default_report_for_offering` — has an explicit `return nil unless source_type` guard, so `nil` is safe (and produces the same behavior as having no Tool at all)
- Remote duplication (`remote_duplicate_url`) — only triggers if set, so leaving it blank is safe

Setting `source_type` to a non-nil, non-LARA value would be risky: `DefaultReportService` would query for a matching ExternalReport, and the offerings controller raises `RoutingError` if none is found (line 161 of `offerings_controller.rb`).

**Alternative — skip Tools, match Client by URL:** Instead of the Tool→Client path, the launch code could find a Client by matching the ExternalActivity's URL against `Client.domain_matchers` or `Client.site_url`. This avoids the need to assign Tools to thousands of resources, but couples the Client lookup to URL patterns rather than explicit associations.

**Alternative — generic launch Client:** Create a single "External Launch" Client with empty `domain_matchers` (no referer enforcement) and use it for all short-lived launch tokens. This is the simplest approach but loses the per-SPA referer validation benefit.

**For create_collaboration.rb tokens:** Same approaches apply — use the Tool's Client, match by URL, or use a generic client.

**For the Devise bearer strategy:** Once all grants have clients, the `grant.client` check already passes. The referer check becomes the question: should it be enforced for launch tokens? These tokens are used by SPAs launched from the Portal — the student's browser navigates to the external runtime, which makes API calls back to the Portal using the token. Since these are browser requests, the `Referer` header will be present, and the referer check would work if the Client has `domain_matchers` configured for the SPA's domain. This actually improves security over the current situation (where `check_for_auth_token` does no referer check at all).

**What about `check_for_auth_token`?:** With client-less grants eliminated, `check_for_auth_token`'s Case A becomes redundant with the Devise bearer strategy (both would authenticate the same grants, though `check_for_auth_token` also extracts the role). The remaining unique cases are peer-to-peer (B/C) and JWT role extraction (D).

**Trade-offs:**
- (+) Eliminates the biggest user-identity divergence
- (+) All AccessGrant tokens work with any endpoint, not just `check_for_auth_token` ones
- (+) Aligns with the external-services doc's recommendation to connect Tools and Clients
- (+) Per-SPA referer validation improves security over current state
- (-) Tool→Client approach requires adding `client_id` to Tool, assigning Tools to resources, verifying no side effects
- (-) Need to create/identify the right Client for each external runtime
- (-) Peer-to-peer and JWT role extraction still need `check_for_auth_token`

### Option B: Replace Client-less Grants with Signed JWTs

**Idea:** Instead of creating a short-lived AccessGrant for runtime launches, mint a short-lived Portal JWT (using the existing `SignedJwt` module) that carries the learner context as claims. The runtime exchanges this JWT for a longer-lived token as it already does today.

**What changes:**
- `create_access_token_with_learner_valid_for` is replaced with `SignedJwt::create_portal_token(user, {learner_id: learner.id, user_type: "learner"}, 180)` (180 seconds = 3 minutes)
- The launch URL passes the JWT as the token parameter
- `check_for_auth_token`'s Case D already extracts the role from JWT claims

**Handling the `Authorization` header format:** The external runtimes currently receive the token as a URL parameter and send it back in an `Authorization: Bearer <token>` header. We cannot update these clients to use `Bearer/JWT`. Instead, update `JwtBearerTokenAuthenticatable` to also accept `Authorization: Bearer <token>` when the token is a JWT (contains dots). This aligns with RFC 6750 (standard `Bearer` for all bearer tokens) and is the same detection logic the OIDC strategy uses. The existing `Bearer/JWT` scheme would continue to work for backward compatibility.

The `check_for_auth_token` method would also need a corresponding update: its Case A currently tries AccessGrant lookup first for `Bearer` tokens. If the lookup fails and the token looks like a JWT (contains dots), it should fall through to JWT decoding (Case D) rather than trying peer-to-peer or raising an error.

**Identifying affected runtimes:** Search the production Portal for ExternalActivities with `append_auth_token = true` — these are the ones that receive the short-lived launch token. Collect their URLs to identify which external repositories need verification. There are likely only 4-5 distinct runtimes. Each can be tested locally by launching from a local Portal with the JWT token to verify they treat the token as opaque and don't make assumptions about its format (e.g., length, character set).

**Trade-offs:**
- (+) No AccessGrant records created at all — eliminates the client-less grant problem entirely
- (+) No database write on every launch (JWTs are stateless)
- (+) Both Devise and `check_for_auth_token` already handle JWT tokens correctly (with the Bearer header update)
- (+) Role information (learner_id) travels in the JWT claims, preserving the existing flow
- (+) Aligning `Bearer` with JWTs follows RFC 6750 and matches the OIDC strategy's approach
- (-) Risk that some runtimes make assumptions about token format (length, no dots, etc.) — needs verification per above
- (-) Short-lived JWTs can't be revoked (though 3-minute lifetime limits exposure)
- (-) Changing JWT strategy detection to also match `Bearer` requires care to avoid conflicts with the existing AccessGrant `Bearer` strategy — strategy ordering and the "contains dots" heuristic must be reliable

### Option C: Separate Authentication from Role Context

**Idea:** Accept that authentication and role context are two different concerns. Keep `check_for_auth_token` but refactor it: authentication delegates to Devise (`current_user`), role extraction becomes a separate concern.

**What changes:**
- Create a `RoleContext` module/concern that extracts role information independently of authentication
- `RoleContext` can read from:
  - JWT claims (for Portal JWTs that carry learner_id/teacher_id)
  - AccessGrant associations (for bearer tokens with a grant)
  - Request params (resource_link_id, as_teacher, etc.)
  - Database associations (current_user.portal_teacher, etc.)
- Controllers that need role context include the concern and call something like `current_role` or `role_context`
- Controllers that only need the user just use `current_user` directly
- `check_for_auth_token`'s authentication logic moves into Devise strategies; its role logic moves into `RoleContext`

**Trade-offs:**
- (+) Clean separation of concerns — authentication and role context are orthogonal
- (+) Makes the "what role?" question explicit — controllers opt into role awareness
- (+) JwtController can use `current_user` + `role_context` instead of the combined `check_for_auth_token`
- (+) Works naturally with OIDC (no role in token → role from params or database)
- (-) More moving parts — new module, new concept to understand
- (-) Still needs to solve the client-less grant and peer-to-peer auth problems at the Devise level
- (-) Risk of over-engineering for a codebase where only one controller truly needs role context

### Option D: Fix `check_for_auth_token` to Work with OIDC

**Idea:** Make minimal changes so `check_for_auth_token` doesn't break when an OIDC token is present. Leave everything else as-is.

The specific problem (from Section 4): when an OIDC-authenticated request hits an endpoint using `check_for_auth_token`, the method sees `Authorization: Bearer <oidc-jwt>`, tries to find an AccessGrant (fails), has no peer params (fails), and raises an exception — even though Devise has already set `current_user`.

**What changes:**
- Modify `check_for_auth_token` Case A: when `AccessGrant.find_by_access_token` returns nil and no peer params are present, instead of raising, fall through to the session fallback (check `current_user`)
- Alternatively: add a new case between A and B that checks if the bearer token looks like a JWT (contains dots) and `current_user` is already set, and returns `[current_user, nil]`

**Trade-offs:**
- (+) Minimal change — one or two lines in `check_for_auth_token`
- (+) All existing endpoints immediately work with OIDC
- (+) No changes to Devise strategies, controllers, or external services
- (-) `check_for_auth_token` gets another branch, making it harder to reason about
- (-) The returned role would be nil for OIDC requests, so JwtController would rely entirely on parameter-based role resolution (which may be fine per the FIXME at line 94)
- (-) Doesn't address any of the underlying complexity — just patches over the OIDC case

### Option E: Do Nothing (Status Quo + OIDC Scoping)

**Idea:** Leave `check_for_auth_token` as-is. OIDC callers only use endpoints that work through Devise/Pundit (like `add_to_class`). If OIDC callers need `check_for_auth_token` endpoints in the future, address it then.

**Trade-offs:**
- (+) Zero risk — no changes to working code
- (+) OIDC's immediate use case (button interactive calling `add_to_class`) works today
- (-) The bifurcation remains undocumented institutional knowledge (though this document now documents it)
- (-) Future OIDC needs (e.g., JwtController for Firebase tokens) will hit the wall described in Section 4
- (-) New developers will continue to be confused about which auth path to use

---

## 7. Discussion Questions

1. **Client-less grants — can we eliminate them?** There are only 2 creation sites, both producing 3-minute tokens. Option A (add clients) and Option B (replace with JWTs) both address this. We'd need to check which external runtimes receive these tokens and whether changing the token format would break them.

2. **Peer-to-peer auth — is it actively used?** Added in 2018-2019 for "LARA to proxy firebase api calls," but LARA uses OAuth2. No evidence of production usage found in the codebase. To verify before deprecating: (a) search the `concord-consortium` GitHub org for `learner_id_or_key` — this parameter name is unique to the peer-to-peer path; (b) search for code that sends a `Client.app_secret` as a Bearer token; (c) cross-reference with the ~25 Clients configured on the production Portal. Note that the peer-to-peer path does not check `domain_matchers` — any Client's `app_secret` is sufficient — so Client configuration alone doesn't indicate whether peer-to-peer is in use. See Section 2.2 for the full verification approach.

3. **OIDC + JwtController — is it needed for the button interactive?** The Cloud Function may need Firebase JWTs for the teacher of a specific student and class. If so, Option D (minimal fix) or the parameter-based path in `handle_initial_auth` would need to work. The `target_user_id` + `resource_link_id` path (lines 115-136) is designed for exactly this kind of elevated-access JWT request.

4. **Referer validation — what would break?** The current Devise bearer strategy enforces referer checks for client-backed grants. `check_for_auth_token` does not. If we unify into Devise, some external services that currently work via `check_for_auth_token` (no referer check) might break if their requests lack referer headers. However, this is distinct from OAuth redirect validation (`redirect_uris`), which only applies during the OAuth authorize flow.

---

## 8. Next Steps

Before choosing a final approach, two research tasks will determine which simplifications are viable:

1. **Verify peer-to-peer auth can be removed.** Follow the verification approach in Section 2.2: search the `concord-consortium` GitHub org for `learner_id_or_key`, cross-reference with production Clients, and check request logs if needed.

2. **Verify client-less grants can be replaced with JWTs (Option B).** Search the production Portal for ExternalActivities with `append_auth_token = true` to identify the ~4-5 distinct runtimes that receive these tokens. Check each runtime's codebase to verify it treats the token as opaque (doesn't make assumptions about format). Test locally by launching from a local Portal with a JWT token.

If both simplifications are confirmed viable, the remaining complexity of `check_for_auth_token` shrinks substantially — peer-to-peer cases (B/C) are removed, client-less grant case (A) is replaced by JWT handling, and the method reduces to JWT role extraction (D) + session fallback (E). At that point, Option A (unifying into Devise) becomes much simpler because there are no client-less grants to accommodate, and the `Bearer` header update from Option B means all JWT tokens flow through Devise uniformly.
