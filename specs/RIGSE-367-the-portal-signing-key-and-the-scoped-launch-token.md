# RIGSE-367: The portal signing key and the scoped launch token

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-367

**Status**: **Closed**

## Overview

rigse gains an RS256 signing key and uses it to mint a short-lived, class-scoped launch token for the Researcher Dashboard, so the dashboard link hands the app a credential that cannot be edited to open a different class and cannot be forged outside the portal. The same key signs the two service-to-service assertions the dashboard's later stories need, and every place rigse verifies one of these tokens checks which audience it was minted for.

Researchers open the Researcher Dashboard from a "Researcher Dashboard" link on each class in the Research Classes table. Behind that link, the portal checks that the researcher may see the class, then sends them to the dashboard carrying a signed ticket that says who they are and which class they opened. The ticket expires on its own and cannot be altered, so a pasted or bookmarked link cannot be edited into opening someone else's class, and nothing outside the portal can make one. This story lays the credential foundation for the rest of the Researcher Dashboard work (RIGSE-368 and the report-service stories verify what this story signs), and closes a hole in an existing shared endpoint: a dashboard ticket for one class cannot be used to obtain read access to a different class's student answers.

## Requirements

### The signing key

- R1. rigse signs RS256 tokens with a private key supplied per environment through configuration (environment variables, following the `JWT_HMAC_SECRET` pattern in `docker-compose.yml` and both ECS task definitions), together with the key's `kid`. The private key exists only in rigse's configuration and is never committed, logged or returned by any endpoint.
- R2. rigse verifies RS256 tokens against a set of public keys keyed by `kid`: the current key's, plus any previous keys configured for a rotation. The verification key is selected by `kid` and the algorithm is pinned to RS256. A token whose `kid` is absent or unrecognized is refused, never verified against a default key.
- R3. The verification key is never chosen by reading `alg` from the token. An HS256 token signed with an RS256 public key as the HMAC secret is refused wherever rigse accepts RS256 tokens. Every RS256 verification passes the public key as an `OpenSSL::PKey` object, never as a PEM string, and names exactly one algorithm, since the `jwt` gem accepts that forged token when the key is a PEM string and the algorithm list includes HS256.
- R4. Staging and production use different keypairs. A token signed with another environment's key is refused, including when it carries the same `kid`.
- R5. There is a documented way for an operator to obtain the current environment's public key as a PEM together with its `kid` (`rake portal_signing_key:public`). That pair is the contract REPORT-141's verifiers accept. rigse adds no JWKS or other public-key endpoint.
- R6. When the signing key is not configured, the dashboard launch is unavailable (R14) and nothing else in the portal changes. No existing HS256 path depends on the new key.

### Audiences and claims

- R7. rigse mints three kinds of RS256 token, each with a distinct `aud`:

  | `aud` | Claims | Lifetime |
  |---|---|---|
  | `researcher-dashboard` | `iss`, `uid`, `user_type: "researcher"`, `scope_kind`, `scope_id`, `iat`, `exp`, and `kid` in the header | 2 hours (R16) |
  | `report-server` | the above plus `is_admin`, `is_project_admin`, `is_project_researcher`, the identity fields report-server's user row requires (`portal_user_id`, `portal_server`, `login`, `first_name`, `last_name`, `email`), and a unique `jti` | 2 minutes |
  | `report-service-functions` | `iss`, `uid`, `iat`, `exp`, and `kid` in the header | 2 minutes |

- R7a. Each RS256 token carries exactly one `aud`, as a string. The `jwt` gem accepts an `aud` array that contains the expected audience, so a multi-audience token would pass more than one check; rigse never mints one and refuses one.
- R8. `iss` on every RS256 token is `APP_CONFIG[:site_url]`, exactly as the HS256 tokens carry it, so that it doubles as `platform_id`.
- R9. The launch token never carries the role flags or any other permission. `scope_kind` and `scope_id` record what was opened and are never treated as authorization: every endpoint that uses them also runs `can_be_researcher_for_clazz?` on the scope. A `researcher-dashboard` token missing either claim is refused wherever it is presented, so an unscoped launch token can never pass a scope check as a caller with no scope.
- R10. Verification of an RS256 token takes the expected audience from the call site. A token with a missing `aud`, or an `aud` other than the one the call site accepts, is refused. The call sites are `JwtBearerTokenAuthenticatable#authenticate!` and `API::APIController#check_for_auth_token`, and each names the audience it accepts.
- R11. No rigse endpoint accepts a `report-server` or `report-service-functions` token as a bearer.
- R11a. rigse accepts a `researcher-dashboard` token as a bearer only on `GET /api/v1/jwt/firebase` with `researcher=true` (R19) and on the `/api/v1/researcher_dashboard/*` endpoints RIGSE-368 adds. Everywhere else, including `jwt/portal`, `jwt/firebase` without `researcher=true`, and every controller that authenticates through the Devise strategy, such a token authenticates no one.
- R12. HS256 portal tokens keep working exactly as before: the five existing minting sites keep minting HS256 with `JWT_HMAC_SECRET`, and rigse keeps accepting them. `JWT_HMAC_SECRET` stays, and no new code signs or verifies with it.

### The launch

- R13. `User#can_be_researcher_for_clazz?(clazz)` is the single definition of the researcher gate: a site admin, a project researcher for the class (unexpired grant), or a project admin for the class. `jwt_controller#firebase` uses it, with unchanged behavior.
- R14. The dashboard is enabled in an environment when both `RESEARCHER_DASHBOARD_URL` and the signing key are configured, and disabled otherwise. `GET /portal/classes/:id/researcher_dashboard` gives a visitor who fails the gate the portal's standard not-authorized handling and mints no token, and answers 404 when the dashboard is disabled.
- R15. For an authorized researcher, the action mints a `researcher-dashboard` token with `scope_kind: "class"` and `scope_id` set to the class's portal id as an integer, and redirects to `RESEARCHER_DASHBOARD_URL` with `token=<jwt>` as the only parameter rigse adds.
- R16. The launch token lives 2 hours, matching the class dashboard's `ExternalReport::ReportTokenValidFor`, held in one named constant. An expired launch token is refused at every rigse call site that accepts it.
- R17. `GET /api/v1/research_classes` rows carry `researcher_dashboard_url`, linking to R14's action, only when the dashboard is enabled and the current user passes the gate for that class.
- R18. The Research Classes table shows a "Researcher Dashboard" link beside "View Roster" when the row carries `researcher_dashboard_url`.

### The Firebase researcher mint

- R19. `GET /api/v1/jwt/firebase?researcher=true&class_hash=...` presented with a bearer that carries `scope_kind` and `scope_id` refuses any `class_hash` whose class is not the scope, and refuses a `scope_kind` it does not recognize, with the endpoint's existing 400 refusal. `can_be_researcher_for_clazz?` still runs for the matching class.
- R20. Callers whose bearer carries no scope, which is every other consumer of the endpoint, get exactly the previous behavior.

### Configuration and secrets

- R21. `RESEARCHER_DASHBOARD_URL`, the signing key and its `kid` are added to `docker-compose.yml`, both task definitions and the parameters of `configs/cloudformation/stack_template.yml`, and the local setup documentation, without defaults that put a key in the repository.
- R22. `PORTAL_SERVICE_SECRET` appears in no code or configuration in the repository (`git grep PORTAL_SERVICE_SECRET -- ':!specs'` returns nothing); the specs name it only to record why the Jira clause deleting it was set aside.
- R23. `REPORT_SERVICE_BEARER_TOKEN` stays, for `get_feedback_metadata` only. No dashboard path in this story or RIGSE-368 uses it, so the Jira Done-when "rigse's configuration holds no bearer for the function app" is met in the form "rigse uses the function app's shared bearer on no dashboard path".

## Technical Notes

- **What master had before this story.** Every portal JWT was HS256 with the shared `JWT_HMAC_SECRET`, with no `aud`; `decode_portal_token` checked signature and expiry only. Its two callers, the Devise strategy and `check_for_auth_token`, route a bearer to the portal-token path by its unverified `iss`. `log-puller`, `te-report-prototype` and the admin-panel backend verify HS256 portal tokens with the same secret.
- **Set-aside Jira clauses.** The Researcher Dashboard launch existed only on the RIGSE-365 spike branch, which is never merged, so clauses deleting or renaming spike-only code (`Launch::PAGE = 'analyze-class'` and its launch parameters, `analyze_url`, `PORTAL_SERVICE_SECRET`, "the `jti` rigse already sets") were set aside and the launch was built fresh under its final names.
- **`REPORT_SERVICE_BEARER_TOKEN` on master** is the credential for `API::V1::StudentsController#get_feedback_metadata`, which the student offerings page calls to show the teacher-feedback notice. The design's "rigse stops holding it" rested on the spike, where it also opened `run_package`.
- **Routing.** Tokens are routed by the `kid` header: with one, RS256 is pinned against the `kid`-selected key and the call site's audience; without one, HS256 is pinned against `JWT_HMAC_SECRET`. A call site that names no audience refuses every RS256 token.
- **The app's expiry handling.** The dashboard app treats a 401 or 403 from rigse as an expired launch and shows a relaunch page, and its Firebase sessions refresh themselves after the custom-token sign-in, so only new rigse calls need a live launch token.
- **The jwt gem** is `jwt 2.10.1`. Probes found it accepts an HS256 token signed with the public key's PEM when handed the PEM string and a list including HS256, and accepts an `aud` array containing the expected value; both are closed by passing key objects, pinning one algorithm and requiring a single-string `aud`.
- **Key configuration.** The PEM private key is stored with its newlines written as `\n` so it fits in one environment value. `PORTAL_PREVIOUS_VERIFY_KEYS` is a JSON object of `kid` to public PEM for rotations. A rotation is two deploys.
- **Consumers of the public key** are report-server and the report-service function (REPORT-141), configured by value keyed by `kid`, bound to the portal's `iss`.

## Out of Scope

- A JWKS endpoint (the later step, when `log-puller` and `te-report-prototype` migrate off `JWT_HMAC_SECRET`).
- Migrating any existing HS256 consumer, or any of the five existing minting sites, to RS256.
- The dashboard API (`GET /api/v1/researcher_dashboard/classes/:id`, `refresh_profile`, `run_package`), and anything that sends the `report-server` or `report-service-functions` token to another service: RIGSE-368.
- Verification of rigse's tokens in report-server and the function, the `jti` nonce cache and `api_tokens.expires_at`: REPORT-141.
- The app's handling of the launch token, and the info page for `page=analyze-class`: RD-3.
- Any compatibility shim for the spike's `page=analyze-class` launch.
- Deleting spike-only code.

## Not Yet Implemented

- Removing `REPORT_SERVICE_BEARER_TOKEN` from rigse — it stays for student feedback metadata (R23); moving that route onto an assertion is a possible follow-up story.
- Enabling the dashboard on the staging and production stacks — the release process updates stacks with their previous template, so the four new parameters reach a stack only through a deliberate template update per environment, with that environment's own generated key and dashboard URL.

## Decisions

### Are HS256 portal tokens subject to the audience rule?
**Context**: The story says "a token with a missing or wrong `aud` is refused at every rigse call site", but every HS256 portal token in circulation carries no `aud`, and the Activity Player, LARA, log-puller and others present them to rigse.
**Options considered**:
- A) The audience rule applies to RS256 tokens only; HS256 tokens are verified exactly as before.
- B) HS256 tokens also gain an `aud` and a missing one is refused, breaking every token issued before the deploy and any HS256 token minted outside rigse.

**Decision**: A. The audience check keeps the three RS256 uses apart; an HS256 token has one use, and anyone holding `JWT_HMAC_SECRET` can forge any `aud` anyway, so adding one buys nothing and breaks live runtimes.

---

### Does this story mint the `report-server` and `report-service-functions` tokens, which nothing sends yet?
**Context**: Their first caller is RIGSE-368's run path.
**Options considered**:
- A) This story adds the minting for all three audiences, with specs, and RIGSE-368 only calls it.
- B) This story mints only the launch token and RIGSE-368 adds the other two.

**Decision**: A. The story defines all three claim sets on the one key, and REPORT-141 needs real tokens of both service audiences from rigse to test its verification against.

---

### Build the launch fresh rather than convert the spike's launch
**Context**: The story describes the launch as a change to an existing action (`Launch::PAGE` deleted, `analyze_url` renamed), which exists only on the spike.
**Options considered**:
- A) Build the route, action, row field and link on master under their final names.
- B) Port the spike's OAuth-grant launch and then convert it.

**Decision**: A, required by the sprint's branching rule: story branches never carry spike code, and clauses that remove spike-only code are set aside.

---

### `REPORT_SERVICE_BEARER_TOKEN` is used on master by student feedback metadata, not by `run_package`
**Context**: The story and `final-design.md` say rigse stops holding the function app's shared bearer. On master it is the credential for `GET /student_feedback_metadata`, which the student offerings page calls to show the teacher-feedback notice.
**Options considered**:
- A) Keep it for feedback metadata; no dashboard path uses it, and the Done-when is restated accordingly.
- B) Remove it from rigse and have report-service accept an `aud: report-service-functions` assertion on `/student_feedback_metadata` too, widening REPORT-141.
- C) Remove it and drop the feedback notice.

**Decision**: A (Doug, 2026-09-23). It keeps a live student feature working without widening another story, and keeps what the story protects: no dashboard path gives rigse a credential that opens `move_student_work` or the importers. B is a reasonable follow-up story.

---

### Where does rigse accept the launch token?
**Context**: The Devise strategy authenticates any valid portal token for every controller. Accepting the launch token everywhere would make it a full rigse API credential, and `jwt/portal` would exchange it for a one-hour unscoped HS256 token with admin claims.
**Options considered**:
- A) Accept it only on `jwt/firebase?researcher=true` and the RIGSE-368 `researcher_dashboard` endpoints; refuse it everywhere else.
- B) Accept it everywhere a portal token is accepted, refusing only at `jwt/portal`.
- C) Accept it everywhere.

**Decision**: A. The app's only rigse calls are those endpoints, so the narrow rule breaks no consumer while closing the `jwt/portal` exchange. It also keeps the token out of the Devise session, which would otherwise serialize a two-hour scoped credential into an unscoped session.

---

### How long does the launch token live?
**Context**: Too short sends a researcher back to the portal mid-session; too long keeps a pasted launch URL live.
**Options considered**:
- A) 2 hours, matching `ExternalReport::ReportTokenValidFor`.
- B) 1 hour, matching `PortalTokenClaims::STANDARD_TTL`.
- C) 8 hours, matching the VM's maximum life.

**Decision**: A. The app's Firebase sessions refresh themselves after the first sign-in, so only new rigse calls need the launch token; two hours matches what researchers already experience with the class dashboard, the app already has a relaunch page, and it is one constant.

---

### The `report-server` assertion's claim set
**Context**: The story lists the launch claims plus the three role flags; report-server finds or creates its user row from its `PortalUserInfo` struct, whose changeset requires every portal field.
**Options considered**:
- A) Exactly the story's list.
- B) The story's list plus the `PortalUserInfo` identity fields.

**Decision**: B. Without `portal_user_id`, `portal_server`, `login`, `first_name`, `last_name` and `email`, a first-time researcher's row cannot be created, and report-server names the researcher's Athena workgroup from the email. The assertion never reaches a browser, so the fields cost nothing in exposure.

---

### Defining "enabled" and making the disabled launch testable
**Context**: The first draft hid the link when "configured" without saying whether the signing key counted; gating on the URL alone would offer a link whose action cannot mint.
**Decision**: "Enabled" means both the dashboard URL and the signing key are configured; the action answers 404 when disabled, and the row field uses the same definition.

---

### `scope_id`'s type
**Context**: The app builds URLs from it and RIGSE-368 and report-server compare it, so a string in one place and an integer in another would be a silent mismatch.
**Decision**: The class's portal id as an integer.

---

### Naming the call sites and the `jwt/firebase` refusal
**Context**: "Refused at every rigse call site" named no call sites, and R19's "refuses" gave no response.
**Decision**: The two decoders (the Devise strategy and `check_for_auth_token`) are named in R10, and the scope refusal uses the endpoint's existing 400, as its other researcher refusals do.

---

### Route by the `kid` header rather than by the header `alg`
**Context**: Both are safe when each branch pins its own algorithm and key.
**Options considered**:
- A) `kid` present means RS256 against the `kid`'s key; absent means legacy HS256.
- B) Header `alg` chooses the branch.

**Decision**: A. It is the property the story names ("the key is chosen by `kid`"), a legacy HS256 token never carries a `kid`, and the probe ran every attack and legacy case against this routing. B reads the one header field the story says must never choose the key.

---

### Extend `create_portal_token` and `decode_portal_token` rather than add parallel RS256 methods
**Options considered**:
- A) One mint and one decode, the audience deciding the algorithm, with `aud:` a required keyword on decode.
- B) New `create_rs256_token` / `decode_rs256_token` beside the untouched HS256 ones.

**Decision**: A. A required keyword makes "every call site names the audience it accepts" enforced by Ruby rather than by review; B would leave the existing decode sites unaware of RS256 tokens.

---

### The scope travels in `Current`, not in `check_for_auth_token`'s return value
**Options considered**:
- A) `Current.token_scope_kind` / `token_scope_id`, beside the existing `minted_via_oidc_client_id`.
- B) Return a third element from `check_for_auth_token` and `handle_initial_auth`.

**Decision**: A. `Current` already carries per-request token facts for these decode paths, resets per request, and leaves the two-element return every caller destructures unchanged.

---

### Keep the legacy HS256 payload's shape
**Context**: The first draft moved the `alg` claim from first to last in the HS256 payload while promising legacy tokens were unchanged.
**Decision**: The HS256 payload keeps `alg` first; the RS256 payload omits it.

---

### Launch specs are controller specs, and the test keypair needs `require "openssl"`
**Context**: `spec/requests` has no sign-in helper here, and `spec_helper.rb` sets its environment before Rails loads, so generating the test key without the require fails every spec file at load.
**Decision**: The launch specs live in `spec/controllers/portal/clazzes_controller_spec.rb` using Devise's `sign_in`, and `spec_helper.rb` requires `openssl` before generating the test keypair.

---

### A normal release does not enable the dashboard on a stack
**Context**: The release skill updates stacks with `--use-previous-template`, so releasing the code adds neither the parameters nor their environment entries.
**Decision**: The README states that enabling the dashboard is a deliberate template update per environment with that environment's own values, after which releases carry them forward with `UsePreviousValue=true`, which also keeps the `NoEcho` key intact.

---

### Omit empty dashboard settings from the task environment
**Context**: The four new stack parameters default to empty, and the template had no precedent for passing an empty parameter into a task definition.
**Decision**: Each entry sits behind an `!If` on its parameter being non-empty with `AWS::NoValue` otherwise, the pattern `PORTAL_PAGES_LIBRARY_URL` already uses, so a stack that has not enabled the dashboard carries no empty variables. The template lints clean with `cfn-lint`.

---

### Check the site admin role first in the researcher gate
**Context**: The gate runs once per Research Classes row, and the neighbouring `has_full_access_to_student_data?` orders its checks cheapest first.
**Decision**: `has_role?('admin')` runs before the two join-count queries; the result is unchanged because the three are OR-ed predicates.

---

### Refuse a launch token that carries no scope
**Context**: The `jwt/firebase` scope check treats a bearer with no scope as an ordinary unscoped caller, so a `researcher-dashboard` token minted without a scope would pass for any class its holder can reach. rigse never mints one, and only the private key can sign one.
**Decision**: `check_for_auth_token` refuses an `aud: researcher-dashboard` token missing `scope_kind` or `scope_id`, so a launch token always arrives scoped (R9).

---

### What R22's "appears nowhere" means
**Context**: `PORTAL_SERVICE_SECRET` appears in no code or configuration, but the specs name it to explain why the Jira clause deleting it was set aside, so a literal repository-wide grep fails.
**Decision**: R22 reads "no code or configuration", checked with `git grep PORTAL_SERVICE_SECRET -- ':!specs'`.
