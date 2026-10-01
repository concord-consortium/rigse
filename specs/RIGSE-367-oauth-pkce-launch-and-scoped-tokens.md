# RIGSE-367: OAuth2 PKCE launch and capability-scoped portal tokens

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-367

**Status**: **Closed**

## Overview

rigse gains an RS256 signing key, an OAuth2 authorization code flow with PKCE for browser apps, and a capability convention for limiting what a token may do, so the Researcher Dashboard can be launched as an ordinary `ExternalReport` and obtain a short-lived token bound to one class without any token ever appearing in a URL. The same key signs the two service-to-service assertions the dashboard's later stories need, and RIGSE-352's minted tokens move onto the same capability convention.

RIGSE-367 was first implemented as PR #1487, whose launch token rode in the dashboard URL; scytacki, the org's architect, requested changes on 2026-09-26, and this spec implements his preferred direction as one PR that replaces #1487, on `RIGSE-367-oauth-pkce-scoped-tokens` from `master`. It was implemented on 2026-09-28 in six step commits and two gap-fix commits; the full rspec suite ran 3,093 examples with 0 failures, and the react-components jest suite 175 tests, all passing.

## Requirements

### The signing key (carried over from #1487)

- R1. rigse signs RS256 tokens with a private key supplied per environment through configuration (`PORTAL_SIGNING_KEY`, a PEM with newlines written as `\n`, and `PORTAL_SIGNING_KEY_ID`, its `kid`), following the `JWT_HMAC_SECRET` pattern in `docker-compose.yml` and both ECS task definitions. The private key exists only in rigse's configuration and is never committed, logged or returned by any endpoint.
- R2. rigse verifies RS256 tokens against public keys keyed by `kid`: the current key's, plus any previous keys configured for a rotation in `PORTAL_PREVIOUS_VERIFY_KEYS` (a JSON object of `kid` to public PEM). The key is selected by `kid` and the algorithm pinned to RS256; a token whose `kid` is absent or unrecognized is refused, never verified against a default key. `kid` is only this routing detail inside `decode_portal_token`: no caller branches on it.
- R3. The verification key is never chosen by reading `alg` from the token. Every RS256 verification passes the public key as an `OpenSSL::PKey` object and names exactly one algorithm, so an HS256 token signed with the public key as the HMAC secret is refused.
- R4. Staging and production use different keypairs; a token signed with another environment's key is refused, including when it carries the same `kid`.
- R5. `rake portal_signing_key:public` prints this environment's `PORTAL_PUBLIC_KEYS` entry, the JSON object `{kid, iss, pem}` that report-server and the function (REPORT-141) are configured with, ready to join the array beside any other portal's. Its `iss` is `APP_CONFIG[:site_url]` exactly as the tokens carry it, trailing slash included, because both verifiers trust a key only for its own issuer and compare the claim as a string; `rake portal_signing_key:generate` prints a new keypair for an operator to store. rigse adds no JWKS or other public-key endpoint.
- R6. When the signing key is not configured, or is configured but does not parse as an RSA private key, nothing that needs it is offered: `oauth_authorize` refuses a scoped client's request with a `server_error` redirect naming `PORTAL_SIGNING_KEY` in the log, as R39 does for an unconfigured audience, so no code is issued that `/oauth/token` could not honour; and every existing HS256 path behaves exactly as before. No existing HS256 path depends on the new key.

### Tokens and claims

- R7. **The access token** is an RS256 JWT following RFC 9068: header `typ: "at+jwt"` and `kid`; claims `iss` (`APP_CONFIG[:site_url]`), `sub` (the user id as a string), `uid` (the user id as an integer, which the portal's decoders and report-server read), `aud` (R8), `client_id` (the `Client`'s `app_id`, for logging and audit only), `scope` (R10) when the client has scopes, `context` when the token is bound to an object (R11), `iat`, `exp` and a unique `jti`. It carries no role flags, no `user_type` and no other permission. A scoped token lives `SignedJwt::SCOPED_ACCESS_TOKEN_TTL` (8 hours) and an unscoped one `SignedJwt::UNSCOPED_ACCESS_TOKEN_TTL` (2 hours).
- R8. The access token's `aud` is a list: always rigse's `APP_CONFIG[:site_url]`, plus the audience of each other service whose capability the token was granted (R13). For `packages:read` that is report-server's URL from `REPORT_SERVER_URL` with any trailing slash removed, never the string `report-server`. report-server compares `aud` entries as exact strings, so REPORT-142's change must compare against its own URL normalised the same way (scheme and host, no trailing slash), which the sprint doc's cross-story note records.
- R9. **The two service assertions** keep their single-string `aud`, their lifetimes and their claim sets from #1487: `aud: "report-server"` (two minutes; `iss`, `uid`, `user_type: "researcher"`, the three portal role flags, report-server's `PortalUserInfo` identity fields `portal_user_id`, `portal_server`, `login`, `first_name`, `last_name`, `email`, a unique `jti`, and `context` naming the class, in place of #1487's `scope_kind`/`scope_id`) and `aud: "report-service-functions"` (two minutes; `iss`, `uid`). rigse mints both and accepts neither as a bearer anywhere.
- R9a. **Which tokens may carry an `aud` list** (scytacki, 2026-09-28). Only the scoped access token (R7, R8) carries a list. The two assertions (R9) always carry exactly one string, and every verifier of an assertion refuses a list, even one that contains its own audience: the `jwt` gem, like `jsonwebtoken` and Joken, accepts any list containing the expected value, which is why #1487's R7a refused lists outright. rigse tests that each assertion's `aud` is a string, and that an access token's `aud` never contains either assertion audience string (`report-server`, `report-service-functions`), so a list-accepting verifier still could not take one as an assertion. The verifiers themselves are report-service's: its function refuses a non-string `aud` (`portal-token.ts:63`) and report-server's mint path compares by string equality, both with tests of a one-element list; REPORT-141/142 add a test that a token with several audiences, including the verifier's own, is refused as an assertion, and keep that refusal on the mint path when REPORT-142's catalog path moves to list membership.
- R9b. **The upgrade path, if report-server ever has to be isolated from rigse**, is an RFC 8693 token exchange: the app would trade its rigse token at rigse for a report-server-only token, rigse would mint for that second audience, and the access token's `aud` would go back to naming rigse alone. It costs a round trip at launch and a second token for RIGSE-368 to forward, which is why the list is used today (R8).
- R10. `scope` is one string of space-separated capability names (RFC 6749 §3.3). A token with no `scope` claim is a full-user credential, limited only by the user's own permissions; every token that exists today (HS256 portal JWTs, `AccessGrant` tokens, sessions) is one, and none of them changes.
- R11. `context` is `{"type": "class", "id": <the class's integer portal id>}`. A token is bound to at most one context and every capability in its `scope` applies to that context. `context.id` is the portal's integer class id and is not report-service's `contextId`, which is the class hash; the spec and the README say so.
- R12. rigse accepts an RS256 token as a bearer only when its header `typ` is `at+jwt` and its `aud` contains `APP_CONFIG[:site_url]`. Every other RS256 token, the assertions included, authenticates no one.

### Capabilities

- R13. rigse defines its capabilities in one registry, each with the context type it requires (or none) and the service it is for:

  | Capability | Context type | Audience |
  |---|---|---|
  | `class:researcher-read` | `class` | rigse |
  | `class:researcher-run` | `class` | rigse |
  | `packages:read` | none | report-server (`REPORT_SERVER_URL`) |
  | `portal-api` | none | rigse |

  A `Client`'s scopes and a token's `scope` may name only registered capabilities.
- R13a. **Capabilities are flat** (scytacki, 2026-09-28). No capability implies another, and each action checks exactly the capabilities it declares, as a plain membership test of the capability string in the token's `scope`; there is no containment or hierarchy logic anywhere. What an app can do is therefore exactly the list on its `Client`: an app that should run packages is given `class:researcher-read` as well as `class:researcher-run` in its configuration, rather than run implying read in code. The dashboard's client carries both (R40).
- R14. A controller declares the capabilities each action accepts. One global `before_action` in `ApplicationController` reads the request's bearer itself through R18's shared decoder, without forcing Warden authentication, and refuses, with 403 and a JSON reason, any request whose verified token carries a `scope` holding none of the capabilities the action declares. An action that declares nothing refuses every scoped token. Reading the header directly is what closes the "lazy Warden" trap RIGSE-352 documented without authenticating, and so without storing a session for, requests that never touch `current_user`; it also means the ceiling applies whenever a scoped bearer is present, even on a request that also carries a session. A bearer that does not verify is ignored by this check and authenticates no one elsewhere. Unscoped credentials are never affected by it.
- R15. `require_token_capability!(capability, object)` passes for an unscoped credential, and for a scoped one only when the token holds `capability` and `object` is the token's context (same type, same id) when the capability requires one. A scoped token without a `context` fails every context-bound check, so it can never pass as an unrestricted caller. Failure is a 403 with a JSON reason.
- R16. The capability is a ceiling, never a grant: an endpoint that passes the capability check still runs its own authorization (`can_be_researcher_for_clazz?`, Pundit) exactly as it would for an unscoped caller.
- R17. The scope is enforced on every verified portal token that carries one, whatever its signing algorithm, so an HS256 token with a `scope` claim is limited exactly as an RS256 one is.
- R18. Scope, context and RIGSE-352's marker are read from a verified token by one shared piece of code, used by the global check (R14), the Devise JWT strategy and `check_for_auth_token`, and stored on `Current`. `check_for_auth_token` loses #1487's launch-token special cases and gains nothing dashboard-specific.

### RIGSE-352's minted tokens under the convention

- R19. `POST /api/v1/jwt/oidc_mint` adds `scope: "portal-api"` to the token it mints, and keeps the `minted_via_oidc_client_id` / `minted_for` marker for the audit trail and the existing log lines.
- R20. The marker is an audit trail only. A verified token that carries the marker and no `scope` is unscoped like any other.
- R21. `API::APIController` declares `portal-api` for every action by default. `JwtController` declares nothing by default (R22), so a minted token is refused on every `jwt/*` action as D9 refuses it today. `confine_service_minted_tokens` is removed: the global check (R14) refuses a `portal-api` token outside the API namespace, as D11 rule 1 does today.
- R22. `JwtController#reject_credential_issuing_callers` keeps refusing OIDC-authenticated callers (D1, unchanged, since it is about the caller rather than the token) and drops the marker check, which R21 now covers.
- R23. A token minted during a request authenticated by a scoped token inherits that request's `scope` and `context`, as it inherits the marker today (D9's "the marker survives every derivation").
- R24. No `AccessGrant` is created while the request's credential carries a `scope`. This extends D11 rule 2, which is otherwise unchanged, to every scoped token, so no scoped token can be turned into an unscoped opaque one.

### Devise authentication of scoped tokens

- R25. The Devise JWT strategy authenticates RS256 access tokens (R12) as well as HS256 portal tokens, and populates `Current` through R18's shared code.
- R25a. The Devise JWT strategy and `check_for_auth_token` accept an RS256 access token only under plain `Bearer`; `Bearer/JWT` stays accepted for HS256 portal JWTs. The global check (R14) reads both schemes.
- R26. The strategy does not store a Rails session when the token carries a `scope` or is an RS256 access token, and stores one exactly as today for an unscoped HS256 portal JWT. This closes RIGSE-352's D10 gap for minted tokens.
- R27. Controllers that accept a scoped token use `current_user` and, where the controller already uses it, Pundit; no new code calls `check_for_auth_token`.

### The OAuth code flow fixes (every client)

- R28. An authorization code is redeemable exactly once, within 5 minutes of issue, and only by the client it was issued to. A second redemption, a late one, or one by another client is refused. Only a grant created by `response_type=code` has a redeemable code: grants created by the implicit flow and by `Client#updated_grant_for` get none, although `generate_tokens` gives every grant one today.
- R28a. *(partial: a mismatched `redirect_uri`, and a missing one for a PKCE code, are refused; refusing a missing one for other codes is deferred until Model My Watershed releases WikiWatershed/model-my-watershed PR #3731, which sends it)* A confidential client redeeming a code that was issued for a `redirect_uri` must present the same one (RFC 6749 §4.1.3): a different one is refused at once. A missing one is accepted and logged with the client's name for one release, because the confidential clients that predate the check may not send it, and becomes a refusal in a follow-up once the logs show none. Codes issued before the deploy stored no `redirect_uri` and are not checked. Only confidential clients matter, since implicit-flow clients never redeem a code, and all but one are Concord's own apps, which the logs will show. The outside one is Model My Watershed (WikiWatershed/model-my-watershed): it sends `redirect_uri` on authorize but not on the token request (`src/mmw/apps/user/sso.py` `get_session_from_code` posts only `code` and `grant_type`, and rauth adds only the client id and secret), so it would break when a missing `redirect_uri` is refused. The follow-up waits on it: if its client is unused it is deleted; if it is used, a PR to Model My Watershed sends `redirect_uri` on the token request, and the refusal ships after their release (scytacki, 2026-09-28). It does POST to the token endpoint, so R30 does not affect it. **Checked 2026-09-28** in CloudWatch Logs Insights over the 90 days of authorize requests `learn-ecs-production` keeps (from 2026-06-30): only three clients use the code flow, and every other client is implicit-flow and never redeems a code. `authoring` (LARA, 504 authorizations) and `codap_document_store` (document-store, 31 authorize requests, all 2026-08-03 to 08-05, but none of them real use: each came from a different residential or mobile IP in a dozen countries, and each IP made exactly two requests, the authorize and the redirect to `/auth/login`, with no sign-in and no return, so no code was ever issued; CODAP v3 registers document-store as a CFM provider at `deprecationPhase: 3`, which disables every capability, so its portal client looks deletable, a cleanup outside this story) use `omniauth-oauth2` (1.3.0 and 1.1.2), whose `build_access_token` sends `redirect_uri: callback_url` on the token request and whose `callback_url` override leaves out the query string, so both send exactly the URI they authorized with; neither app's `Concord::AuthPortal` strategy (`lib/concord/auth_portal.rb` in each, a subclass of `OmniAuth::Strategies::OAuth2` that sets only its name, client options and user info) overrides `callback_url` or `build_access_token`. `model-my-watershed` is in use: 26 authorizations on production, the latest on 2026-09-27, and one from `staging.modelmywatershed.org`, so its client cannot simply be deleted, and the refusal of a missing `redirect_uri` waits on a Model My Watershed release that sends it.
- R29. A grant's opaque `access_token` authenticates only when its expiry is set and in the future, on every path (`bearer_token_authenticatable`, `token_authenticatable`'s `?access_token=`, `check_for_auth_token`). An unredeemed code-flow grant's token authenticates no one, and `check_for_auth_token` refuses a NULL expiry as an ordinary refusal rather than a `NoMethodError`.
- R30. `/oauth/token` and `/auth/concord_id/access_token` accept POST only. `/oauth/token` has a CORS entry allowing POST from any origin without credentials, since the code and verifier, not the origin, authenticate the request.
- R31. `prune!` also removes code-flow grants whose code expired unredeemed.

### PKCE and scoped clients

- R32. `Client` gains `scopes`: the space-separated capabilities the client may request, validated against R13's registry and editable in the admin client form. A client with no scopes behaves exactly as today.
- R33. The token a client receives from `/oauth/token` is decided by its type and scopes: a client with scopes receives the scoped access token (R7); a public client without scopes, redeeming a PKCE code, receives the unscoped access token (R7); a confidential client without scopes receives today's `AccessGrant` token. The implicit flow is unchanged. A client with scopes may not use the implicit flow (`unauthorized_client`), so a scoped token never travels in a URL.
- R33a. A scoped client never receives an opaque grant, by any path: `Client#updated_grant_for` refuses a scoped client, `AccessGrant` refuses to create any grant for one other than a code-flow grant, and a scoped client's report is refused by the offering launch route (`offerings/:id/external_report/:report_id`, which names any report by id and would otherwise put a two-hour full-user token in its URL) with a 404, since only a class launch knows how to start the code flow.
- R34. A public client may use `response_type=code` only with a PKCE `code_challenge` and `code_challenge_method=S256` (RFC 7636); `plain` and a missing challenge are refused with `invalid_request`. A confidential client may send a challenge, which is then verified. Public clients without scopes keep the implicit flow exactly as today, and may also use the code flow with PKCE, receiving the unscoped access token (R33), which is the path off the implicit flow the unification design points to.
- R35. `oauth_authorize` accepts `scope` (defaulting to all of the client's scopes; any capability outside them is `invalid_scope`) and `context` (`class:<integer id>`). A context is required when the requested scope includes a context-bound capability (`invalid_request` otherwise) and refused when it names a type the scope's capabilities do not take. `login_hint` behaves as today.
- R35a. Every error redirect from `oauth_authorize`, the existing ones included, carries the request's `state` when it had one (RFC 6749 §4.1.2.1); today `ValidationResult#error` sends only `error` (`access_grant.rb:30-33`), so a client that checks `state`, as a PKCE client must, cannot tell a genuine error response from a forged one.
- R36. At authorize, for a class context, the portal runs `can_be_researcher_for_clazz?` for the requesting user whenever the scope includes `class:researcher-read` or `class:researcher-run`. A user who fails it, and a class that does not exist, get the same `access_denied` error redirect, so the endpoint cannot be used to enumerate classes. The class is bound into the code.
- R37. At `/oauth/token`, a code issued with a challenge requires a `code_verifier` whose S256 hash matches, a `redirect_uri` identical to the one used at authorize, and, for a public client, no secret; a public client authenticates by `client_id` plus verifier. Failures are RFC 6749 §5.2 errors (`invalid_grant`, `invalid_client`, `invalid_request`) with status 400 or 401. If `grant_type` is sent it must be `authorization_code` (`unsupported_grant_type` otherwise).
- R37a. Every response from the token endpoint's new path, success or error, carries `Cache-Control: no-store` (RFC 6749 §5.1).
- R38. For a scoped client the response is `{"access_token": <jwt>, "token_type": "Bearer", "expires_in": <SCOPED_ACCESS_TOKEN_TTL>, "scope": <granted scope>}` with no `refresh_token`; for a public client without scopes it is the same without `scope`, with the unscoped lifetime. Both clients' code grants are created with no opaque `access_token` or `refresh_token` at all, and are deleted on redemption, so no opaque token ever exists for a scoped client or a public client's code flow. A code issued with a scope is refused if its client no longer has scopes. The token is signed before the code is spent: a signing failure answers `server_error` and leaves the code redeemable, and the code is then spent by a conditional delete, so a concurrent redemption still cannot also succeed.
- R39. When a requested capability's audience is not configured (`packages:read` without `REPORT_SERVER_URL`), authorize refuses the whole request with a `server_error` redirect and logs the missing setting by name; it never issues a token missing a capability the client asked for.

### The Researcher Dashboard as an ExternalReport

- R40. *(the two admin rows are created per environment at release)* The dashboard is configured per environment as data, not code: an `ExternalReport` with `report_type: "class"`, `supports_researchers: true`, its `url`, `name` and `launch_text`, linked to a public `Client` whose scopes are `class:researcher-read class:researcher-run packages:read` and whose `redirect_uris` hold the dashboard's URL. There is no `RESEARCHER_DASHBOARD_URL`, no dashboard-specific route or action, and no dashboard name in rigse's code. The README documents the two rows an administrator creates, and the settings (R46) they depend on.
- R41. `ExternalReport#url_for_class`, for a report whose client has scopes, creates no grant and adds no token: it appends `authDomain` (the portal's root URL, built from the request's protocol and host as `root_url` is for an ExternalActivity OAuth2 launch, `offerings_controller.rb:73`), `classId` (the class's integer id) and `loginHint` (the user's id), and nothing else, ignoring `researcher`. Reports whose client has no scopes launch exactly as today.
- R42. `GET /api/v1/research_classes` rows carry `external_reports: [{id, name, launch_text, url}]`, listing every `ExternalReport` with `report_type: "class"` and `supports_researchers: true`, with `url` the existing `classes/:id/external_report/:report_id` launch carrying `researcher=true` (which an unscoped report already reads, through `url_for_class`'s `additional_params[:researcher]`, and a scoped one ignores), only when the current user passes the researcher gate for that class. The gate is evaluated once for the whole list through `User#researcher_clazz_ids`.
- R43. The Research Classes table renders each of a row's `external_reports` as a link, labelled with its `launch_text` or, when blank, its `name`, beside "View Roster".

### The researcher gate and the Firebase researcher mint

- R44. `User#can_be_researcher_for_clazz?(clazz)` is the single definition of the researcher gate: a site admin, a project researcher for the class with an unexpired grant, or a project admin for the class. It is defined through `User#researcher_clazz_ids(clazz_ids)`, the batched form, and `JwtController#firebase` uses it with unchanged behaviour.
- R45. `GET /api/v1/jwt/firebase` with `researcher=true` declares `class:researcher-read`. Presented with a scoped token, it refuses any `class_hash` whose class is not the token's context with the endpoint's existing 400 refusal, and still runs the researcher gate for the matching class. Without `researcher=true`, or on POST, a scoped token is refused (R14). Callers with an unscoped credential get exactly today's behaviour.

### Configuration and secrets

- R46. `PORTAL_SIGNING_KEY`, `PORTAL_SIGNING_KEY_ID`, `PORTAL_PREVIOUS_VERIFY_KEYS` and `REPORT_SERVER_URL` are added to `docker-compose.yml`, both task definitions and the parameters of `configs/cloudformation/stack_template.yml` (each entry behind an `!If` on its parameter being non-empty, as `PORTAL_PAGES_LIBRARY_URL` is), and the README, without defaults that put a key in the repository.
- R47. `PORTAL_SERVICE_SECRET` and `RESEARCHER_DASHBOARD_URL` appear in no code or configuration (`git grep -e PORTAL_SERVICE_SECRET -e RESEARCHER_DASHBOARD_URL -- ':!specs'` returns nothing).
- R47a. `docs/portal-authentication-unification-design.md` describes the capability convention (a new section), records D10 as closed for scoped tokens, and updates its account of the JWT strategy, since that document is where the portal's authentication paths are described and scytacki's review cites it.
- R47b. The portal's logs never record an OAuth or token credential. `config.filter_parameters` covers only `password` and `password_confirmation` today (`config/application.rb:54`), so Rails' `Parameters:` line for every token request logs `client_secret` and `code` in full to CloudWatch, and this change would add `code_verifier`. It gains `client_secret`, `code_verifier` and `token` (matched as a substring, as Rails matches symbols, so `access_token`, `refresh_token` and `firebase_token` are covered) and `code` matched exactly, so `zipcode` and `country_code` stay readable. `client_id`, `redirect_uri`, `grant_type`, `state` and `code_challenge_method` stay readable, since they identify a request and carry no secret. Nothing in the app reads filtered parameters; ActiveRecord's `inspect` hides the same attributes, which is intended (Doug, 2026-09-28).
- R48. `REPORT_SERVICE_BEARER_TOKEN` stays, for `StudentsController#get_feedback_metadata` only; no path in this story or RIGSE-368 uses it.

## Technical Notes

- **Relationship to the Jira clauses.** The story's launch clauses (`GET /portal/classes/:id/researcher_dashboard`, a token in `?token=`, `aud: researcher-dashboard`, `scope_kind`/`scope_id`, the "Researcher Dashboard" link text, `researcher_dashboard_url`) are superseded by R33 to R43 per scytacki's review. Its clauses deleting spike-only code (`Launch::PAGE`, `analyze_url`, `PORTAL_SERVICE_SECRET`, the `jti` "rigse already sets") are set aside as #1487 set them aside, since that code is not on `master`. Its security clauses all survive: alg confusion (R3), unknown `kid` (R2), per-environment keys (R4), no JWKS (R5), no role flags in anything a browser holds (R7), the scope never treated as authorization (R16), the Firebase class match (R45), and `REPORT_SERVICE_BEARER_TOKEN` (R48).
- **The `jwt` gem is 2.10.1.** A throwaway probe on 2026-09-28 confirmed: `JWT.decode` with `aud: site_url, verify_aud: true` accepts a token whose `aud` is `[site_url, report_server_url]` and refuses one whose `aud` is `"report-server"`; the `typ` header round-trips; an HS256 token signed with the public key's PEM is refused (`JWT::IncorrectAlgorithm`) when the key object is passed and RS256 pinned; and `Base64.urlsafe_encode64(SHA256(verifier), padding: false)` reproduces RFC 7636 appendix B's S256 challenge. #1487's R7a, which refused an `aud` array, is replaced by R12's "contains", since the access token's list is now intentional; the assertions keep a single string, and rigse never accepts them.
- **report-server's check is a string equality today** (`claims["aud"] == audience` in `ReportServerWeb.Api.PortalToken.verify`, `portal_token.ex:16` on `REPORT-142-catalog-and-url-profile`). REPORT-141/142 change it to membership for the catalog pipeline, with its own URL as the audience and `packages:read` required; the mint pipeline's `report-server` check is unchanged. report-server reads no `scope_kind` or `scope_id`.
- **Warden skips every strategy when the session already holds a user** (`_perform_authentication`, warden `proxy.rb:328-341`). A request carrying both a portal session cookie and a scoped bearer therefore has `current_user` from the session, but the global check (R14) and `check_for_auth_token` read the header themselves, so the bearer's ceiling still applies. The dashboard's calls are cross-origin without credentials, so they carry no portal cookie in any case.
- **Verified: a per-token `store?` stops the session (stage 4, 2026-09-28).** A throwaway request spec prepended a `store?` to the JWT strategy that answers false when the token carries `scope`, then called `GET /auth/user` with a bearer and again without one on the same cookie jar. An unscoped HS256 token signed in both requests (today's D10 gap, reproduced); a scoped one authenticated the first and the second was redirected to login. A `Set-Cookie` is still sent, since the request touches the session for CSRF, but it carries no user. The first request in the process redirected to login whichever case ran first, a test warm-up effect unrelated to the change, which the implementation's specs should not depend on.
- **Devise strategy names.** All three custom strategies are classes named `BearerToken`; the `store?` override is a per-instance method on the JWT strategy and does not depend on Devise's `authentication_type`, which is nil for these strategies.
- **`url_for_class` has no class hash or class URL for scoped reports** because the app asks rigse for the class's metadata with its token (RIGSE-368), and `class_hash` is deliberately not in the token (`final-design.md` 11.1).
- **Admin.** `Admin::ClientsController` permits `app_id, app_secret, client_type, domain_matchers, name, redirect_uris, site_url` (`admin/clients_controller.rb:72`) and renders them in `app/views/admin/clients/_form.html.haml` and `_show.html.haml`; `scopes` joins them.
- **Test setup** carries over from #1487: `spec_helper.rb` requires `openssl` before generating a test keypair and setting the signing-key environment, since it runs before Rails loads.

### As built

Implemented on 2026-09-28, one commit per step, each through a `cc-code-review` pass until it reported nothing actionable. Departures from the plan and review decisions, by step:

#### The portal signing key and the RS256 tokens

- **Departure: `create_access_token` guards its own `aud`.** The review found that nothing stopped a caller passing an assertion audience into an access token's `aud` list, which R9a forbids, and that step 1's specs built access tokens by hand instead of through the real encoder. `create_access_token` now raises `SignedJwt::Error` unless the list starts with `site_url` and names neither `report-server` nor `report-service-functions`, and the specs run it through `decode_portal_token` (claims, `typ`, `kid`, a fresh `jti`, `context` present only when given) and check each refused list.
- **Rejected: shorten `PortalSigningKey`'s header comment.** The review called it a duplicate of the README. It is #1487's header, which scytacki reviewed, and it carries the two facts a reader of the code most needs there: the literal `\n` form of the key and that staging and production must never share a keypair.

#### Capabilities and the scoped-token check

- **Departure: one Authorization-header parser for all three readers.** The review found, and confirmed with a probe, that the global check matched `Bearer <jwt>` and `Bearer/JWT <jwt>` with exactly one space while `check_for_auth_token` accepted any whitespace, so a scoped or service-minted token sent as `Bearer<TAB><jwt>` or with two spaces passed the global check unseen and was then accepted by `check_for_auth_token` as a full-user credential on every API action, including `jwt/portal`. `PortalBearer.raw_token` is now the only parser: the global check, the Devise JWT strategy's `jwt_token_value` and `check_for_auth_token`'s `extract_bearer_token` all call it. Specs send the three padded forms to an undeclared action and a marked token with a tab to `jwt/portal`, all refused; restoring the single-space pattern fails both.
- **Comments name what they describe, not the ticket:** references to "RIGSE-352" in the new code comments were reworded (the service-mint marker, oidc_mint, Warden's lazy authentication), and the comments in `routes.rb`, `mounted_engines_spec.rb` and the confinement spec that still named the deleted `confine_service_minted_tokens` now name `enforce_token_capabilities`.

#### The OAuth code-flow fixes

- **Departure: the implicit flow's redirect is logged as `[FILTERED]`.** The review found that R47b was not met by `filter_parameters` alone: Rails logs `Redirected to <location>` from `response.filtered_location`, which filters a Location's query string but never its fragment, and the implicit flow puts a week-long access token in the fragment (`#access_token=…`). `config.filter_redirect << /[#&]access_token=/` makes Rails log such a redirect as `[FILTERED]`; the spec checks that and that a code-flow redirect still logs with only `code` filtered.
- **Tests added for two behaviours the step had none for:** `check_for_auth_token` refusing a grant whose expiry was never set as an expired grant (R29), and a routing spec that both token routes answer POST and are not routable by GET (R30).

#### PKCE and scoped clients

- **Departure: a malformed `code_challenge` is refused at authorize.** The review found that only presence and `code_challenge_method` were checked, so a 300-character challenge reached the 255-character column and raised `ActiveRecord::ValueTooLong`, a 500 for the user. A challenge must now match RFC 7636's 43 to 128 unreserved characters (`AccessGrant::PKCE_VALUE`, which the verifier check shares) or authorize answers `invalid_request` with `state`.
- **Departure: a change of a client's scopes cancels what it no longer covers.** R33a was enforced only when a grant was created, so an existing client an admin gives scopes kept its implicit-flow or report grants, usable as full-user tokens for up to a week, and a code issued before a scope change redeemed under the old scope for up to five minutes. A save that changes a client's scopes now deletes its pending codes, and, when it leaves the client scoped, every grant holding an opaque token; and the token endpoint signs only the capabilities the grant and the client still share, answering `invalid_grant` when none remain.
- **Tests added:** a public client without scopes redeeming a PKCE code (and refused without a challenge), a scoped confidential client redeeming with its secret and no PKCE, and a `code_challenge` sent as an array refused as `invalid_request` rather than raising.

#### The Researcher Dashboard as an ExternalReport

- **Departure: project admins may follow a class report's launch link.** The review found that the Research Classes rows list class reports for every class the researcher gate admits, which includes the class's project admins, while `Portal::ClazzPolicy#external_report?` admitted teachers, site admins, class researchers and class students but not project admins, so a project admin who is not a researcher saw a "Researcher Dashboard" link that answered not authorized. `external_report?` now also admits `class_project_admin?`, as `materials?` and `roster?` already do for the same role. This widens every class report's launch, not only the dashboard's, to a role that already has full access to the class's student data (`has_full_access_to_student_data?`); the launch still grants nothing a scoped report's authorize step does not check again.
- **Test added:** a Research Classes row whose class fails the researcher gate lists no reports even when one supports researchers.

#### After the six steps: comparing the code with both specs

A requirement-by-requirement comparison found every requirement implemented and no code contradicting one. It found two code gaps and several untested behaviours, which one further commit closes:

- **Departure: a confidential client's PKCE code needs its `redirect_uri`.** R37 requires an identical `redirect_uri` for a code issued with a challenge, but the confidential path's one-release leniency (R28a) also let such a code redeem without one. A client that sends a challenge is new to this flow, so the leniency no longer applies to it.
- **`Portal::LearnersController#report` answers 404 for a scoped client's report**, as the offering routes do. It launches the offering's default report through `url_for_offering`, which raises for a scoped client; only an admin who made a scoped report an offering's default could reach it.
- **Tests added:** a context the scope does not take, or a malformed one (`invalid_request` with `state`); another client's code, on both paths; a narrowed scope signing only what remains and `invalid_grant` when nothing does; the class launch route end to end, redirecting with `authDomain`, `classId` and `loginHint` and creating no grant; `authDomain` from `request.protocol`'s `"https://"`; an RS256 token with no `kid`; the admin form saving normalised scopes; and a Jest test of the table's report links. Not added: specs for the two rake tasks (a key generator and a printer) and assertions on the `server_error` log lines.

#### After review (2026-09-30)

PR #1489's review asked for these; each is a commit on top of the reviewed ones.

- **One kind of token from `/oauth/token`.** A public PKCE client without scopes gets the unscoped RS256 access token instead of an opaque `AccessGrant` token, so its grant is deleted at redemption and its requests need no database lookup. Both responses say `token_type: "Bearer"`. The cost is revocation, which nothing performs on an opaque grant in practice (no logout or password-change path deletes one), and the `domain_matchers` referer check, which scoped tokens and portal JWTs already skip.
- **Lifetimes.** 8 hours for a scoped token: the portal session idles out after 90 minutes, so an expiry nearly always means a new login, and a scoped token reaches one context with its gate run on every call. 2 hours for an unscoped one, matching what a portal-launched report already gets. Until RIGSE-371, an unscoped token can be traded at `jwt/portal` for self-renewing portal JWTs, as an opaque token can.
- **The marker fallback (R20) was removed rather than kept for one release.** report-service caches a minted token for one task run, so only tokens in flight across the deploy are affected, for seconds, and they stay with a caller that uses only `/api`. `AccessGrant`'s guard is `refuse_under_scoped_tokens`, and the containment specs build tokens as `oidc_mint` does, plus a scope-without-marker case each.
- **`Bearer` only for the access token (R25a)**, so the legacy scheme does not spread; `PortalBearer.legacy_scheme?` is the one test for it.
- **No session for any access token (R26)**, so the unscoped token cannot be traded for a cookie.
- **`Client#find_grant_for_user` skips grants that still hold a code**, so a report launch never reuses a public client's code-flow grant, which has no opaque token.
- **`Client#confidential?`** in `matching_response_type`, so a client with no type is refused the code flow without PKCE on the scoped branch too.
- **Docs.** The convention moved from the unification doc's Section 11 to `docs/token-capabilities.md`; `docs/external-services.md` describes the code flow with PKCE, scoped report launches and the dashboard's setup; the unification doc's Section 10 describes RIGSE-352's containment through the scope, and its D10 subsection covers all three bearer strategies.

## Out of Scope

- The dashboard app's PKCE client, its `authDomain` allowlist, its handling of `classId` and `loginHint`, and re-authorizing when the token expires: RD-3.
- The dashboard API (`GET /api/v1/researcher_dashboard/classes/:id`, `refresh_profile`, `run_package`) and anything that sends the assertions: RIGSE-368, rebased onto this branch.
- report-server's and the function's verification changes: REPORT-141 and REPORT-142.
- Creating the dashboard's `ExternalReport` and `Client` rows in staging and production (admin data, per environment, at release).
- A JWKS endpoint; migrating any HS256 consumer or minting site to RS256.
- Refresh tokens; RFC 8707 `resource` indicators; token introspection or revocation.
- Moving other `ExternalReport` launches, or the implicit flow, to PKCE; the unification design's later steps.
- Revisiting RIGSE-352's D3 (a minted teacher token bound to one class), which becomes adding a capability under this convention.
- The legacy token response's `expires_in` (it reports `Devise.timeout_in`, 90 minutes, while the grant lives a week) and its 200-with-`error` failure shape, both unchanged.
- The researcher materials page never showing class reports, because `API::V1::ClassesController` omits `supports_researchers` from `external_class_reports` (`classes_controller.rb:165-172`): a latent bug noticed here and left for its own fix.

## Not Yet Implemented

- Refusing a confidential client's code redemption that sends no `redirect_uri` (other than for a PKCE code, which is refused now) — deferred until Model My Watershed, the one code-flow client that omits it, releases WikiWatershed/model-my-watershed PR #3731; until then the portal logs each such redemption with the client's name (R28a).
- Creating the Researcher Dashboard's `Client` and `ExternalReport` rows in each environment, and setting `PortalSigningKey`, `PortalSigningKeyId` and `ReportServerURL` on each stack — release and admin steps (R40, R46), documented in the README.
- Release steps: run `AccessGrant.prune!` from a console straight after deploying (the first authorize would otherwise delete every unredeemed code ever issued inside a user's request); check which production class reports have `supports_researchers` set, since they will appear on Research Classes and project admins may now open them; and run the GET-callers check on any production portal other than learn.concord.org before its deploy.
- Specs for the two `portal_signing_key` rake tasks, and assertions on the `server_error` log lines (R6, R39) — not added.
- The `codap_document_store` portal client had no real use in 90 days and looks deletable — a cleanup outside this story, pending an owner's decision.

## Decisions

### Judgment call: where the access token's report-server audience comes from
**Context**: The token needs an `aud` entry naming report-server, and something has to map a capability to its audience.
**Options considered**:
- A) A code registry maps each capability to its audience; report-server's is `REPORT_SERVER_URL`, which RIGSE-368 needs anyway.
- B) A `resources` field on `Client` naming the audiences explicitly.
- C) The fixed string `report-server`.

**Decision**: A. Capabilities are declared by controllers in code, so their audiences belong in the same registry; B duplicates what the scopes already imply, and C would let an access token pass report-server's mint-assertion audience check.

---
### Judgment call: keep Warden's session precedence
**Context**: A request with both a session and a scoped bearer is authenticated by the session, so `current_user` does not carry the bearer's scope.
**Options considered**:
- A) Keep Warden's behaviour and document it.
- B) Prefer a portal JWT bearer over an existing session on every request.

**Decision**: A. B would change authentication for every existing same-origin caller that sends a bearer alongside its cookie. Since the self-review, the global check reads the bearer itself (R14), so the ceiling applies regardless of which credential Warden chose.

---
### Judgment call: the gate runs at authorize, not at the launch link
**Context**: `external_report?` admits class teachers and students too, so a non-researcher could follow a scoped report's launch link.
**Options considered**:
- A) Leave the launch action's policy as it is; the researcher gate runs at authorize (R36), and only researchers see the link (R42).
- B) Add a researcher check to the launch action for scoped reports.

**Decision**: A. The link now carries nothing but a class id, so following it grants nothing; the authorize step is the only place a credential is issued and the only gate that matters, and B would add a dashboard-shaped branch to a generic action.

---
### Low confidence: production may already have class reports with `supports_researchers` set
**Context**: R42 lists every class-type report that supports researchers on every Research Classes row. If production has such reports today (for example the class dashboard), they will appear there alongside the Researcher Dashboard, which changes a page researchers use. This could not be checked from here.
**Options considered**:
- A) List every class report that supports researchers (R42 as written), accepting that existing ones appear.
- B) List only class reports whose client has scopes, i.e. the ones built for this launch.
- C) Check production's `external_reports` before deciding.

**Decision**: A. It is scytacki's design as written ("the Research Classes table would list class reports that support researchers"), and `supports_researchers` is exactly a report's claim that it handles a researcher launch, so a class report carrying it appearing for researchers is the intended outcome rather than a side effect; today such a report reaches no researcher at all, because the materials page's class-report JSON omits the flag (Out of Scope). B would make the list depend on how the client authenticates, which is not what the flag means. The row's launch URL carries `researcher=true` so an unscoped report launches in researcher mode (R42). No local or repository data shows production's rows (the local database has no `external_reports` or `clients`), so the release checks production's class reports with the flag set and says in the PR which will appear.

---
### Low confidence: making the token endpoint POST-only may break an existing client
**Context**: R30 makes `/oauth/token` and `/auth/concord_id/access_token` POST-only, as scytacki asked. `omniauth-oauth2` defaults to POST, but a client configured for GET would stop being able to log in, and production's clients could not be checked from here.
**Options considered**:
- A) POST-only for both routes (R30 as written).
- B) POST-only for `/oauth/token`, leave `/auth/concord_id/access_token` accepting GET.
- C) POST-only, with GET requests logged for one release first.

**Decision**: A. scytacki named it a defect; RFC 6749 §3.2 requires POST; both routes are the same action, so leaving one on GET keeps the defect under another name; and a GET carries the client secret or verifier in the query, which is the URL-exposure problem this story exists to remove. The only GET caller in the repository is the auto-generated `auth_controller_spec.rb` example (`GET access_token`), which changes with it. The release was to check the portal's access logs for GET requests to either route before deploying, which is C's information without C's extra release. Checked on 2026-09-28 in CloudWatch Logs Insights against learn.concord.org's production portal log group (`learn-ecs-production`, account `612297603577`): over the preceding 90 days, no request reached either token route by GET (the one `Started GET "/oauth/token...` line was `/oauth/token/info`, an unrouted scanner probe from `45.148.10.20` on 2026-09-02), while the last week alone logged 49 token exchanges by POST (2026-09-21 to 2026-09-28), so the query demonstrably sees token traffic. No other of the account's 182 log groups carried token traffic. A production portal logging to another account would need the same check before its own deploy.

---
### How long does an authorization code live?
**Context**: R28 says 5 minutes. RFC 6749 §4.1.2 recommends at most 10; the dashboard redeems immediately, and existing confidential clients redeem server-side within a second or two.
**Options considered**:
- A) 5 minutes.
- B) 60 seconds.
- C) 10 minutes.

**Decision**: A, 5 minutes, in one named constant. Every client redeems immediately, so the lifetime only has to cover a slow redirect and clock skew between the portal's hosts; 5 minutes is inside the RFC's recommendation with room for both, and single use (R28) is what actually stops replay.

---
### Error shape on the token endpoint's existing path
**Context**: R37 gives the new PKCE and scoped path RFC 6749 §5.2 errors with 4xx statuses. The existing confidential path answers 200 with `{"error": "Could not find application"}`; clients may depend on that.
**Options considered**:
- A) RFC errors on the new path only; the existing path is unchanged.
- B) RFC errors on every path.

**Decision**: A. The new path has no existing callers, so it can be correct from the start, while existing confidential clients (LARA and others via `omniauth-oauth2`) have a live contract whose failure handling could not be checked from here; changing it buys nothing this story needs. It is listed in Out of Scope beside the legacy `expires_in`.

---
### What happens to `packages:read` without `REPORT_SERVER_URL`?
**Context**: The first draft dropped it silently from the granted scope, so the app would learn only from the response's `scope`, or from a 401 at report-server.
**Options considered**:
- A) Drop it from the granted scope (R39 as written).
- B) Refuse the whole authorization with `invalid_scope`.
- C) Refuse to save a `Client` with `packages:read` when `REPORT_SERVER_URL` is unset.

**Decision**: B, as `server_error` rather than `invalid_scope`, since the request is valid and the portal is misconfigured (R39). A hands the app a token that fails later somewhere else, which is the "every failure looks identical" problem RIGSE-368 exists to avoid; C checks configuration at the wrong time, since an environment variable can change after the row is saved.

---
### A global check that forces authentication would start storing sessions on API endpoints
**Context**: RIGSE-352's `confine_service_minted_tokens` forces `current_user` only outside `API::APIController` (`application_controller.rb:71-80`), and the JWT strategy stores a session for every token (no `store?` override; `skip_session_storage` is `[:http_auth]`). A global check forcing authentication on every request would therefore create Rails sessions for HS256 bearers on API endpoints that never touched `current_user` before.

**Decision**: Fixed in R14 and R18: the check reads the bearer through the shared decoder without going through Warden, which also makes the ceiling apply when a session is present too.

---

### Authorize error redirects drop `state`
**Context**: `ValidationResult#error` builds its redirect with `error:` alone (`access_grant.rb:30-33`). RFC 6749 §4.1.2.1 requires `state` on an error response when the request carried one, and a PKCE client that validates `state` would reject every genuine error.

**Decision**: Fixed with R35a, for every error redirect, since adding a parameter an existing client ignores changes nothing for it.

---

### Every grant carries a code, not only code-flow grants
**Context**: `generate_tokens` (`access_grant.rb:110`) gives the implicit flow's grants and `Client#updated_grant_for`'s report grants a `code` too. They are never handed out, but R28 as first written made "a code" redeemable by its client without saying which grants have one.

**Decision**: Fixed in R28: only `response_type=code` grants have a redeemable code.

---

### Enabling the dashboard is admin data with nowhere written down
**Context**: R40 moves the dashboard from a stack parameter to two admin rows, but only the settings were documented (R46), so an operator enabling an environment had no record of which rows and field values to create.

**Decision**: Fixed in R40: the README documents the rows and the settings they depend on.

---

### `authDomain`'s source was unstated
**Context**: R41 said "the portal's root URL" without saying which, while the existing OAuth2 launch passes `root_url` from the request (`offerings_controller.rb:73`).

**Decision**: Fixed in R41 to match, so a portal reached under more than one host sends the researcher back to the host they used.

---

### Is the `aud` list right for the token's second recipient?
**Decision**: Yes: RFC 7519 allows an array, and RFC 9700 accepts a small set of resource servers when one is not feasible. He asked for R9a (which tokens may carry a list, with a test that a multi-audience token cannot pass as an assertion) and R9b (RFC 8693 named as the upgrade path).

---
### Are the three defaults right?
**Decision**: Yes: `context=class:<id>`, `authDomain` with a build allowlist, and a separate `class:researcher-run`. He asked for R13a, capabilities are flat.

---
### One release of logging, then refusing, for a missing `redirect_uri`?
**Decision**: Yes, with the mismatch refused at once. Model My Watershed is the one outside client and does not send it; R28a records the plan for it.

---
### Use his diagram?
**Decision**: Not needed; the page's sequence diagram is enough.

---
### F1 (blocker): a scoped report could launch through the offering route with a full-user token in its URL
**Context**: `Portal::OfferingsController#external_report` names any report by id and calls `url_for_offering`, which always creates a grant and puts its token in the URL, and the offering policy admits the class teacher, admins and researchers.

**Decision**: Fixed with R33a.

---

### F2 (major): the confidential path did not bind the code to its `redirect_uri`
**Decision**: Fixed with R28a, lenient for one release on a missing value.

---
### F3 (major): a present but malformed key passed the preflight and failed after the code was spent
**Decision**: Fixed in R6 (the key must parse) and R38 (sign before spending).

---
### F4 (minor): the report-server assertion dropped #1487's `user_type`
**Decision**: Restored in R9.

---
### F5 (minor): a scoped client's code grant carried an unusable opaque token
**Decision**: The claim in R38 is now true rather than reworded: such a grant has no opaque token.

---
### F6 (major): the first commit's assertion spec needed a constant from the second
**Decision**: A plan sequencing defect; `PortalAssertions` moves to the capabilities step (implementation.md).

The review's question about `aud` normalisation between rigse and report-server is answered in R8.

---
### Judgment call: one-argument `decode_portal_token` rather than #1487's required `aud:` keyword
**Context**: #1487 made every call site name the audience it accepted, because rigse then accepted a launch token on some endpoints and not others.
**Options considered**:
- A) Keep the one-argument signature; rigse accepts exactly one kind of RS256 token, its access token, and where it may be used is the capability check's job.
- B) Keep the keyword, with one possible value.

**Decision**: A. Audience no longer varies by call site, so the keyword would carry no information, and the question "may this token be used here" now has one answer in one place (R14) rather than two.

---
### Judgment call: the assertions leave the `ResearcherDashboard` namespace
**Context**: #1487 put them in `ResearcherDashboard::Assertions`, and R40 keeps the dashboard's name out of the portal's launch code.
**Options considered**:
- A) `PortalAssertions`, since each is named for the service it is for.
- B) Keep `ResearcherDashboard::Assertions` for RIGSE-368.

**Decision**: A. Nothing in them is the dashboard's, and RIGSE-368 calls them by the service's name either way.

---
### Judgment call: a public client without scopes may also use the code flow with PKCE
**Context**: R34 requires PKCE for a public client's code flow and keeps the implicit flow for public clients without scopes; it does not say whether such a client may choose the code flow.
**Options considered**:
- A) Allow it, issuing today's opaque token, so an existing public client can move off the implicit flow without also taking scopes.
- B) Refuse it until the client has scopes.

**Decision**: A. It is the OAuth-recommended migration path the unification design is heading toward, and nothing depends on refusing it. The token it issues was changed after review from the opaque `AccessGrant` token to the unscoped access token (see As built, "After review").

---
### The researcher Firebase mint's declaration landed two steps before its class check
**Context**: As first written, the capabilities step declared `class:researcher-read` on `jwt/firebase` and the researcher gate step added `require_token_capability!`, so at the commit between them a class-scoped token would pass the declaration with no check that the class was its own. No such token could be issued at that commit, but each commit should be safe on its own.

**Decision**: Fixed: the declaration moves to the researcher gate step, beside the check.

---

### The code-flow step called a method the PKCE step defines
**Context**: The built `access_token` checks `verifies_code_verifier?` on the confidential path, which the PKCE step adds, so the code-flow step would not load on its own.

**Decision**: Fixed: the code-flow step's condition is `access_grant.nil? || !access_grant.spend_code!`, and the PKCE step adds the verifier to it.

---

### Five ALTERs on `access_grants`
**Context**: `add_column` five times is five `ALTER TABLE` statements, each a table rebuild on MySQL 5.7 (the local server here; production moved to Aurora 3 under `docs/mysql-8-upgrade/`), on a table with a row per user and client.

**Decision**: Fixed: one `change_table ... bulk: true`, verified to emit a single `ALTER TABLE access_grants` with all five columns.

---

### The first authorize after deploy pays for every unredeemed code ever issued
**Context**: `prune!` runs inside `get_authorize_redirect_uri`, and the new clause deletes code-flow grants that were never redeemed, which nothing has deleted before.

**Decision**: Fixed as a release step in the code-flow step: run `AccessGrant.prune!` from a console straight after deploying.

---
