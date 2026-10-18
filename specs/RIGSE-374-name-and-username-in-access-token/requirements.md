# Put the researcher's name and username in the access token

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-374
**Repo**: https://github.com/concord-consortium/rigse
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

A scoped access token from `/oauth/token` gains three claims naming the user it was issued to: `first_name`, `last_name` and `username`. The Researcher Dashboard reads them from the token it already holds, so its header (RD-9) can show whose account the page is signed in as.

## Project Owner Overview

The Researcher Dashboard's new header has a place for the signed-in researcher's name, with their username in muted text under it, so a researcher who works under more than one account can see at a glance which one the page is using. Today the dashboard knows only the researcher's numeric user id, so the header has nothing to show.

This story has the portal put the name and username into the sign-in token it already gives the dashboard. No new screen, endpoint or setting is involved, and nothing changes for any other portal client. The dashboard side is already built on RD-9's branch and starts showing the name as soon as the portal sends it.

## Background

The Jira story is the authoritative scope; this spec records what the code check found and the requirements that follow from it.

RIGSE-367 built the scoped access token and RIGSE-368 (merged as `9f948f6c0`) moved the dashboard's API onto it. `AuthController#issue_access_token` signs it through `SignedJwt.create_access_token` (`rails/lib/signed_jwt.rb`) with `iss`, `sub`, `uid`, `aud`, `client_id`, `iat`, `exp`, `jti`, `scope` and, when bound to an object, `context`. An unscoped access token, issued to a public client with no scopes, has the same claims without `scope` and `context`.

The portal already names these values elsewhere:

- `POST /api/v1/jwt/portal` (`jwt_controller.rb`) puts `first_name` and `last_name`, straight from `user.first_name` and `user.last_name`, in its researcher and plain-user claims.
- `GET /auth/user` (`AuthController#user`) returns the login as `username`, beside `first_name` and `last_name`.
- The report-server assertion (`PortalAssertions.report_server`) carries `login`, `first_name`, `last_name` and `email`, which report-server's `dashboard_token_controller.ex` stores on its `users` row.

The dashboard's side exists on `RD-9-ui-improvements` (`f24a1d6`): `tokenUser()` in `app/src/shell/oauth.ts` decodes the access token's payload, without verifying it, and reads `first_name`, `last_name` and `username`. It treats a missing, `null` or non-string value as empty, trims each, joins the two names, and shows no user when both names are empty. Its demo harness and tests use the same three keys. Against today's token it finds no name, so the header shows no user.

### Where the token goes

The story's Note says the token reaches report-server and never report-service's functions or the runner. The code check confirms both halves:

- **report-server** receives the access token on `/api/v1/packages/list` and `/packages/resolve` (`packages:read`), from the browser and, on `/packages/resolve`, from rigse too: `run_package` hands the bearer it was called with to `Catalog.resolve` (`catalog.rb`), which sends it as the `Authorization` header, and `Upstream` logs no header or body. `PortalToken.verify_access_token` (`server/lib/report_server_web/api/portal_token.ex`, `origin/master` `ceaaf23`) checks the RS256 signature by `kid`, `iss`, `exp`, the `at+jwt` type, that `aud` lists report-server, and the route's capability. `Joken.verify/2` runs with no claim config, so nothing restricts the claim set. `Packages.reader/1` reads only `iss` and `uid`, and no claim is logged or stored.
- **The runner and report-service's functions never receive it.** The dashboard's `run_package` call sends only package identities and versions; rigse builds a new body for the function from a Firebase session token, Firebase class tokens and the report-server assertion (`run_package.rb`), and the runner gets a Firebase session token and a report-server API token minted from that assertion (`ensure-vm.ts`). The functions' verifier (`portal-token.ts`) accepts only a single-string `aud`, so it would refuse an access token anyway.
- **The browser** holds the token in memory only (`oauth.ts`: "the access token is never stored"), and sends it to the portal and to report-server. Every page load runs the code flow again (`start.ts`), so a reload gets a fresh token.

### Personal data

The name and login are personal data, so the question is where they newly appear. They reach the browser of the user they describe, and report-server, which already receives them, with the email, in the assertion. No new service, store or log receives them, and the token is never written to `localStorage`, Firestore or a log. Anything that holds the token can now read the name without asking the portal, and the only holders are those two. This story adds no email, roles or other identity fields, so the token stays at what the header needs.

## Requirements

### The claims

- R1. A scoped access token (one `create_access_token` signs with capabilities) carries three more top-level claims: `first_name` from `user.first_name`, `last_name` from `user.last_name`, and `username` from `user.login`.
- R2. The values are the stored attributes as they are, in the form the portal JWT gives them: no trimming, no fallback, and a `nil` attribute signed as JSON `null`. Non-ASCII names are carried as UTF-8 text. This holds by construction, since the values go in unconverted; no test pins the `nil` case.
- R3. Every scoped access token carries them, whichever client it is issued to. Nothing keys on the dashboard's `client_id`.
- R4. An unscoped access token is unchanged: it has none of the three claims.

### What stays the same

- R5. Every other claim, the header (`typ`, `kid`, `alg`), both lifetimes and the `/oauth/token` response body are unchanged. The scope endpoint's response is unchanged.
- R6. rigse reads none of the three claims: authorization keeps using `uid`, and a token minted during a request a scoped token authenticated inherits only `scope` and `context` (`TokenScope.inherited_claims`), as now. The claims are for display.
- R7. The portal JWT, the two service assertions, the Firebase tokens and `/auth/user` are unchanged.

### Tests and docs

- R8. A unit spec of `SignedJwt.create_access_token` shows a scoped token carrying the user's first name, last name and login under the three keys, with three distinct values, so a swapped or misnamed claim fails; and an unscoped token having none of the three keys.
- R9. The scoped flow's request spec (`spec/requests/scoped_oauth_flow_spec.rb`, the code exchange) shows the token `/oauth/token` issues to the dashboard's client carrying the same `first_name` and `last_name` as `POST /api/v1/jwt/portal` gives the same user, and `username` equal to the user's login. The portal JWT is minted on the session the spec already signs in with: the scoped token itself is refused at `jwt/portal`, which declares no capability it holds (the same file's "is refused wherever no capability it holds is declared"). The unscoped exchange in `spec/controllers/auth_controller_spec.rb` shows none of the three keys.
- R10. `docs/external-services.md`'s Researcher Dashboard section names the three claims and says they are for display only. The README's **Scopes** paragraph, which describes what a scoped client's token carries and calls the unscoped one "the same JWT with no `scope` or `context`", names them too and leaves them out of the unscoped token.

## Technical Notes

- **Files:** `rails/lib/signed_jwt.rb` (`create_access_token`), `rails/spec/libs/signed_jwt_spec.rb`, `rails/spec/requests/scoped_oauth_flow_spec.rb`, `rails/spec/controllers/auth_controller_spec.rb`, `docs/external-services.md`, `README.md` (the **Scopes** paragraph, line 692).
- **Column shape:** `users.first_name` and `users.last_name` are `string(100)`, nullable, default `""`; `login` is `string(40)`. Validation requires a letter or digit in each name, but older rows can hold `""` or `NULL`, which R2 passes through.
- **Measured** (throwaway `rails runner` in the test environment, the real `sign_rs256` and `decode_portal_token`, then deleted): a token signed with the three claims decodes with them intact; `Zoë` is carried as UTF-8 text and a `nil` first name as `null`; `TokenScope.apply!` accepts it and `inherited_claims` stays `{scope, context}`; the token grows from 759 to 841 characters for a typical name. report-server serves through Bandit, whose default header limit is far above that. A second throwaway, with the three claims added to `create_access_token` for the run, showed a session-minted `jwt/portal` token for a `confirmed_user` giving `first_name "joe"`, `last_name "user"`, equal to the access token's, and the 77 existing examples in `signed_jwt_spec.rb`, `scoped_oauth_flow_spec.rb` and `auth_controller_spec.rb` passing unchanged, so no current spec pins the claim set closed.
- **Factory values:** `FactoryBot.create(:user)` gives `first_name 'joe'`, `last_name 'user'` and a unique `login_...`, three distinct values, so R8 and R9 need no custom names to catch a swap.
- **RIGSE-369** (spec'd on `RIGSE-369-delete-the-clue-class-token`) edits `run_package.rb`, `catalog.rb`, `settings.rb`, `runner_tokens.rb`, their specs, `researcher_dashboard_helper.rb`, `researcher_dashboard_controller_spec.rb` and README lines 690 and 701 to 707. This story's only shared file is the README, at line 692, one unchanged line from RIGSE-369's line 690; a throwaway `git merge-file` of both edits against `master`'s README merged with no conflict, so the two merge in either order.

## Out of Scope

- Any change in researcher-dashboard: `tokenUser()` already reads these keys (RD-9).
- Any change in report-server or report-service.
- Email, roles, `full_name` or any other identity claim.
- Refreshing the name inside a live token: a name changed mid-session shows from the next page load, which gets a new token; an open page keeps the old name until its token expires, at most 8 hours later.
- Editing RIGSE-367's spec, whose R7 lists the token's claims as of that story.

## Open Questions

### RESOLVED: Judgment call: every scoped token, or only the dashboard client's?
**Context**: The Done-when names the dashboard's client; the What names the scoped token.
**Options considered**:
- A) Every scoped access token, keyed on capabilities being present.
- B) Only tokens whose `client_id` is `researcher-dashboard`.

**Decision**: A. The signer has no notion of a particular client today, and B would hardcode one app id into it. A scoped client is an app the user signs in to, which is told who signed in, as an OIDC client is; an admin creates scoped clients, so no unreviewed third party receives the names.

### RESOLVED: Judgment call: pass the names through, or normalize them?
**Context**: Legacy rows can hold `""` or `NULL`; the token could omit or trim such values.
**Options considered**:
- A) Pass the stored values through, `nil` as `null` (the portal JWT's form).
- B) Trim, and omit a claim whose value is blank.

**Decision**: A. The story asks for the portal JWT's form, and `tokenUser()` already trims and treats `null` or a missing key as empty, so B would add a second normalizer with no reader.

### RESOLVED: Judgment call: where the claims are documented
**Context**: `docs/token-capabilities.md` covers capabilities; `docs/external-services.md` describes the dashboard's token and its `context` claim.
**Options considered**:
- A) `docs/external-services.md`, beside the sentence on the `context` claim.
- B) `docs/token-capabilities.md`.

**Decision**: A. The claims grant nothing, so they do not belong with capabilities; the dashboard section is where a reader looks for what its token carries.

## Self-Review

Roles: Security Engineer (personal data, claim exposure), QA Engineer (testability of R8 to R10), Senior Engineer (consistency with the portal JWT and the token code), the consumer (RD-9's `tokenUser()`), and Product Manager (agreement with the story as it now reads).

### Security Engineer

#### RESOLVED: Personal data section asserted something unchecked
The section said the portal "already shows that user's name on every portal page". No layout or header helper was found that does so, so the claim was dropped; the argument stands without it (the names reach only their own user's browser and report-server, which already has them).

### QA Engineer

#### RESOLVED: R9's comparison cannot use the scoped token to mint the portal JWT
`scoped_oauth_flow_spec.rb` shows `POST /api/v1/jwt/portal` refusing the dashboard's token, since `jwt/portal` declares none of its capabilities. R9 now says the portal JWT comes from the signed-in session, which `check_for_auth_token` accepts when no bearer is sent (`jwt_controller_spec.rb` mints it that way), and which gives a plain user's `first_name` and `last_name`.

### Product Manager

#### RESOLVED: Background described the story's Note as uncorrected
The Note has since been rewritten to say the token never reaches report-service's functions or the runner, so "The code check corrects the second half" no longer matched the story. The Background now says the check confirms both halves.

### Security Engineer (second pass)

#### RESOLVED: "Where the token goes" left out rigse's own forwarding
`ResearcherDashboardController#run_package` passes the request's bearer (`PortalBearer.raw_token`) to `RunPackage`, and `Catalog.resolve` sends it to report-server's `/packages/resolve` as the `Authorization` header. The recipient is the same report-server, so the holder set and the personal-data argument are unchanged, but the list read as if only the browser sent it. The report-server bullet now names both senders and notes that `Upstream` logs no header or body.
