# Put the researcher's name and username in the access token

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-374

**Status**: **Closed**

## Overview

A scoped access token from `/oauth/token` gains three claims naming the user it was issued to: `first_name`, `last_name` and `username`. The Researcher Dashboard reads them from the token it already holds, so its header (RD-9) can show whose account the page is signed in as. An unscoped access token is unchanged.

## Requirements

### The claims

- R1. A scoped access token (one `create_access_token` signs with capabilities) carries three more top-level claims: `first_name` from `user.first_name`, `last_name` from `user.last_name`, and `username` from `user.login`.
- R2. The values are the stored attributes as they are, in the form the portal JWT gives them: no trimming, no fallback, and a `nil` attribute signed as JSON `null`. Non-ASCII names are carried as UTF-8 text. *(Holds by construction, since the values go in unconverted; no test pins the `nil` case.)*
- R3. Every scoped access token carries them, whichever client it is issued to. Nothing keys on the dashboard's `client_id`.
- R4. An unscoped access token is unchanged: it has none of the three claims.

### What stays the same

- R5. Every other claim, the header (`typ`, `kid`, `alg`), both lifetimes and the `/oauth/token` response body are unchanged. The scope endpoint's response is unchanged.
- R6. rigse reads none of the three claims: authorization keeps using `uid`, and a token minted during a request a scoped token authenticated inherits only `scope` and `context` (`TokenScope.inherited_claims`). The claims are for display.
- R7. The portal JWT, the two service assertions, the Firebase tokens and `/auth/user` are unchanged.

### Tests and docs

- R8. A unit spec of `SignedJwt.create_access_token` shows a scoped token carrying the user's first name, last name and login under the three keys, with three distinct values, so a swapped or misnamed claim fails; and an unscoped token having none of the three keys.
- R9. The scoped flow's request spec (`spec/requests/scoped_oauth_flow_spec.rb`) shows the token `/oauth/token` issues to the dashboard's client carrying the same `first_name` and `last_name` as `POST /api/v1/jwt/portal` gives the same user, and `username` equal to the login. The unscoped exchange in `spec/controllers/auth_controller_spec.rb` shows none of the three keys.
- R10. `docs/external-services.md`'s Researcher Dashboard section names the three claims and says they are for display only. The README's **Scopes** paragraph names them too and leaves them out of the unscoped token.

## Technical Notes

- **Where the token goes.** report-server receives it on `/api/v1/packages/list` and `/packages/resolve`, from the browser and, on resolve, from rigse forwarding the dashboard's bearer (`run_package` to `Catalog.resolve`; `Upstream` logs no header or body). `PortalToken.verify_access_token` checks signature by `kid`, `iss`, `exp`, the `at+jwt` type, `aud` and the route's capability, with no claim whitelist, and `Packages.reader/1` reads only `iss` and `uid`. report-service's functions and the runner never receive the access token: the run path sends them a Firebase session token and a report-server token minted from the assertion. The browser holds the token in memory only, and every page load runs the code flow again.
- **Personal data.** The names reach only the browser of the user they describe and report-server, which already stores the name, login and email from the report-server assertion. No new service, store or log receives them.
- **Column shape:** `users.first_name` and `users.last_name` are `string(100)`, nullable, default `""`; `login` is `string(40)`. Older rows can hold `""` or `NULL`, which R2 passes through.
- **Measured:** a token for a typical name grows by about 100 characters (868 to 974 in one run), far below Bandit's header limit. `Zoë` round-trips as UTF-8 and a `nil` first name signs as `null`.
- **Factory values:** `FactoryBot.create(:user)` gives `joe`, `user` and a unique `login_...`, three distinct values, so R8 and R9 need no custom names to catch a swap.
- **Consumer:** RD-9's `tokenUser()` (`app/src/shell/oauth.ts`) decodes the payload unverified, trims each value, treats a missing, `null` or non-string value as empty, and shows no user when both names are empty.
- **Verification:** deleting the merge, moving it outside `if capabilities`, or swapping the two names each fails exactly the two tests aimed at it. A local end-to-end run with RD-9's dev server showed the header naming the researcher, with the claims in the dashboard's scoped token and absent from an unscoped one.

## Out of Scope

- Any change in researcher-dashboard: `tokenUser()` already reads these keys (RD-9).
- Any change in report-server or report-service.
- Email, roles, `full_name` or any other identity claim.
- Refreshing the name inside a live token: a name changed mid-session shows from the next page load; an open page keeps the old name until its token expires, at most 8 hours later.
- Editing RIGSE-367's spec, whose R7 lists the token's claims as of that story.

## Decisions

### Every scoped token, or only the dashboard client's?
**Context**: The Done-when names the dashboard's client; the What names the scoped token.
**Options considered**:
- A) Every scoped access token, keyed on capabilities being present.
- B) Only tokens whose `client_id` is `researcher-dashboard`.

**Decision**: A. The signer has no notion of a particular client, and B would hardcode one app id into it. A scoped client is an app the user signs in to, told who signed in as an OIDC client is, and only an admin creates scoped clients.

---

### Pass the names through, or normalize them?
**Context**: Legacy rows can hold `""` or `NULL`; the token could omit or trim such values.
**Options considered**:
- A) Pass the stored values through, `nil` as `null` (the portal JWT's form).
- B) Trim, and omit a claim whose value is blank.

**Decision**: A. The story asks for the portal JWT's form, and `tokenUser()` already trims and treats `null` or a missing key as empty, so B would add a second normalizer with no reader.

---

### Where the claims are documented
**Context**: `docs/token-capabilities.md` covers capabilities; `docs/external-services.md` describes the dashboard's token and its `context` claim.
**Options considered**:
- A) `docs/external-services.md`, beside the sentence on the `context` claim.
- B) `docs/token-capabilities.md`.

**Decision**: A. The claims grant nothing, so they do not belong with capabilities. The README's **Scopes** paragraph was added later, since it called the unscoped token "the same JWT with no `scope` or `context`".

---

### How R9 gets the portal JWT to compare against
**Context**: The scoped token is refused at `jwt/portal`, which declares none of its capabilities.
**Options considered**:
- A) Mint the portal JWT with the scoped token.
- B) Mint it on the session the request spec already signs in with.

**Decision**: B. With no bearer, `check_for_auth_token` uses the session and returns the plain-user claims with `first_name` and `last_name`. The example checks the portal JWT against the user's own names first, so it cannot pass on two missing keys.

---

### Where the claims are added
**Context**: The claims could be added by the signer or passed in by its one production caller, `AuthController#issue_access_token`.
**Options considered**:
- A) In `create_access_token`, inside `if capabilities`.
- B) A `claims:` keyword on `create_access_token`, filled by the controller.

**Decision**: A. The signer already decides what a scoped token carries (`scope`), and the spec helpers that call it then sign tokens shaped like production's with no change. B adds a parameter whose only caller passes the same three values.

---

### A new request example, or extending the exchange test
**Context**: The exchange test already decodes the scoped token's claims.
**Options considered**:
- A) A separate example that also mints the portal JWT.
- B) Add the names and the `jwt/portal` call to the exchange test.

**Decision**: A. The exchange test checks single use and the grant's deletion; a `jwt/portal` call in the middle would replace `response` between its assertions and mix two concerns.

---

### Tokens issued before the deploy
**Decision**: No change: RD-9 runs the code flow on every page load and never stores the token, so a reload shows the name; only a page left open keeps its old token, for up to 8 hours.

---

### The header comment on `create_access_token`
**Context**: The planned comment spent two lines on where each key name came from.
**Options considered**:
- A) Keep the provenance in the comment.
- B) One line stating the contract.

**Decision**: B. "A scoped token also names its user (`first_name`, `last_name`, and the login as `username`) for display, never for authorization." The provenance is recorded here and in the story.
