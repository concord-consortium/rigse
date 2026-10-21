# Let the Researcher Dashboard get the researcher's name and username from `/auth/user`

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-374

**Status**: **Closed**

## Overview

A new `profile` capability lets a scoped access token call `/auth/user`, which answers it with the user's id, names and username and nothing else. The Researcher Dashboard's client gets `profile` in its scopes, so its header (RD-9) can ask the portal whose account the page is signed in as. The access token itself carries no name claims: RFC 9068 section 6 says a client must not inspect its access token, and our other apps never decode theirs. The dashboard's call to `/auth/user` is RD-14.

## Requirements

### The capability

- R1. `TokenCapabilities::REGISTRY` gains `profile` (`TokenCapabilities::PROFILE`): no context, accepted by the portal. It is named to match the OIDC scope, so a future UserInfo endpoint can gate on the same capability.
- R2. `AuthController` declares `profile` on `user` only. A scoped token without `profile` is still refused 403 at `/auth/user`, as it is today.

### What `/auth/user` answers

- R3. A request whose credential is scoped (which, after R2, means its token holds `profile`) gets exactly `provider`, `id` and an `extra` holding `first_name`, `last_name`, `full_name` and `username`. It gets no `info` (so no `email`, OIDC's separate `email` scope), and no `user_id`, `roles` or `domain`.
- R4. Every other credential (a session, an unscoped access token, an HS256 portal JWT, an `AccessGrant` token) gets the same response as before, key for key.
- R5. `/auth/user` answers CORS preflight and `GET` from any origin, in the static allowlist beside `/api/v1/researcher_dashboard/*`, so the dashboard can call it with its bearer.

### The access token

- R6. `SignedJwt.create_access_token` is unchanged: a scoped access token carries no name or username claims under any spelling.

### The dashboard's client

- R7. The README's "Enabling the Researcher Dashboard" and `docs/external-services.md` list the dashboard client's scopes as `class:researcher-read class:researcher-run packages:read profile`.

### Tests and docs

- R8. The scoped flow's request spec gives its dashboard client `profile`, and shows `/auth/user` answering the dashboard's token with exactly the R3 body, built from the researcher's own distinct values, so an extra field or a swapped value fails. It also shows the token's payload as an exact key set (`iss sub uid aud client_id iat exp jti scope context`), so a name claim added later fails. Its examples of a refused scoped token use actions that declare none of the dashboard's capabilities.
- R9. A spec shows a signed-in session still getting `email`, `user_id`, `roles` and `domain` from `/auth/user`, and a request spec shows the R5 preflight.
- R10. `docs/token-capabilities.md`'s capability table lists `profile`; the README's **Scopes** paragraph names it among the capabilities.

## Technical Notes

- **How the token reaches `user`.** `verify_logged_in` calls `current_user`, and Warden's Devise JWT strategy authenticates the RS256 bearer without storing a session (RIGSE-367). `enforce_token_capabilities` has already applied the token's scope, so `TokenScope.scoped?` tells the action which response to give.
- **Session and bearer together.** A same-origin request carrying both a portal session and a `profile` token is answered for the session's user, since Warden prefers the session, but still with the R3 body, since the bearer's scope applies. It does not arise for the dashboard: on another origin, a page cannot read a cookie-authenticated response, since the static CORS block sends no `Access-Control-Allow-Credentials`.
- **`/auth/user` no longer answers credentialed cross-origin requests.** rack-cors uses the first allow block whose origin and resource both match, so `/auth/user` in the static `origins '*'` block is used ahead of the `allow_cors` block (`credentials: true`). Where `allow_cors` is enabled, a `*.concord.org` page could read `/auth/user` with only its session cookie; it no longer can. A GitHub code search of the organization for `auth/user` found no browser caller from another origin: LARA's OmniAuth strategy, CLUE's scripts and the Classroom add-on call it from servers, and the portal's own page header calls it same-origin.
- **Values.** The names and login pass through as stored; a `nil` name is JSON `null`, as in the full response.
- **Verification.** Removing the CORS line, the declaration, either branch of the `scoped?` test, swapping two names in the narrow body, or dropping a name field from the full response each fails the tests aimed at it, and so does adding a name claim to `create_access_token`. A local run with the dashboard's dev server against this branch read the narrow body from `/auth/user` cross-origin with the dashboard's own token, and a cookie-only request from that origin could not be read.
- **Deploying.** The dashboard's client on staging and production is admin data: an admin adds `profile` to its scopes on the client form after deploy. Changing a client's scopes cancels its pending codes, which costs a user mid-login one retry.

## Out of Scope

- The dashboard's call to `/auth/user` and its header: RD-14.
- An OIDC UserInfo endpoint or ID token.
- An `email` capability.
- Answering `/auth/user` for the bearer's user when a session is also present.

## Decisions

### Names from an API, or claims in the access token?
**Context**: The header needs the researcher's name. PR #1490 put `first_name`, `last_name` and `username` in the scoped access token for the dashboard to decode; review pointed out that RFC 9068 section 6 says the client must not inspect its access token, that CLUE, the AP and portal-report never decode theirs, and that the names would also reach report-server, which receives the token and does not need them.
**Options considered**:
- A) A `profile` capability declared on `/auth/user`, which the dashboard calls with its bearer.
- B) Keep the claims in the access token under RFC 9068 section 2.2.2's registered names, `given_name`, `family_name` and `preferred_username`.

**Decision**: A. B is smaller, but the dashboard would still be reading its access token, against section 6, and the token's format stays the portal's to change. A costs the dashboard one request per page load and a researcher-dashboard story (RD-14).

---

### What a `profile` token gets from `/auth/user`
**Context**: The full response nests the id at the top, `email` under `info`, and names, `user_id`, `roles` and `domain` under `extra`. OIDC's `profile` scope covers names, not email.
**Options considered**:
- A) The same envelope with `info` dropped and `extra` cut to the four name fields.
- B) A flat object of the five fields.

**Decision**: A. A client reads the names at the same paths whichever credential it holds, and `provider` is a constant, not data about the user. `user_id` repeats `id`, so it goes with the fields the story names as excluded.

---

### Restrict on any scope, or on holding `profile`?
**Decision**: Any scope (`TokenScope.scoped?`). After R2 the two are the same set of requests, and keying on the scope means a capability declared on `user` later still gets the narrow body unless the action is changed on purpose.

---

### The CORS entry
**Context**: The story does not mention CORS, but the dashboard calls `/auth/user` from its own origin, and the static allowlist does not name it.
**Options considered**:
- A) Add `/auth/user` to the static `origins '*'` block.
- B) Leave it to environments that set `allow_cors`.

**Decision**: A, as RIGSE-368 did for the dashboard's own endpoints. Another origin can read the response only for a bearer it already holds (the block sends no `Access-Control-Allow-Credentials`, so a cookie-authenticated answer stays unreadable), and no credentialed cross-origin caller exists to lose its `allow_cors` headers (Technical Notes).
