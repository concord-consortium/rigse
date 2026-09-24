# The portal signing key and the scoped launch token

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-367
**Repo**: https://github.com/concord-consortium/rigse
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

rigse gains an RS256 signing key and uses it to mint a short-lived, class-scoped launch token for the Researcher Dashboard, so the dashboard link hands the app a credential that cannot be edited to open a different class and cannot be forged outside the portal. The same key signs the two service-to-service assertions the dashboard's later stories need, and every place rigse verifies one of these tokens checks which audience it was minted for.

## Project Owner Overview

Researchers will open the Researcher Dashboard from a "Researcher Dashboard" link on each class in the Research Classes table. Behind that link, the portal checks that the researcher may see the class, then sends them to the dashboard carrying a signed ticket that says who they are and which class they opened. The ticket expires on its own and cannot be altered, so a pasted or bookmarked link cannot be edited into opening someone else's class, and nothing outside the portal can make one.

This story lays the credential foundation for the rest of the Researcher Dashboard work (RIGSE-368 and the report-service stories verify what this story signs). It also closes a hole in an existing shared endpoint: a dashboard ticket for one class must not be usable to obtain read access to a different class's student answers.

## Background

RIGSE-367 is the first implementation story under the Researcher Dashboard feature (RIGSE-359 to 363), derived from `final-design.md` section 11.1 (the signing key), section 4 (the launch contract) and section 3 (the renames). The Jira description is the authoritative scope and is not restated in full here; this spec records how it lands on master.

**What master has today.** rigse signs every portal JWT with one shared HMAC secret, `JWT_HMAC_SECRET`, through `SignedJwt.create_portal_token` (`rails/lib/signed_jwt.rb:12`), which sets `alg`, `iss`, `iat`, `exp` and `uid` and no `aud`. `SignedJwt.decode_portal_token` (`rails/lib/signed_jwt.rb:33`) pins HS256 and verifies signature and expiry only. It has two callers, the Devise strategy `JwtBearerTokenAuthenticatable` (`rails/lib/jwt_bearer_token_authenticatable.rb:9`), which authenticates `current_user` for every controller, and `API::APIController#check_for_auth_token` (`rails/app/controllers/api/api_controller.rb:34`), which the API controllers call directly. Both route a bearer to the portal-token path with `SignedJwt.portal_token?`, which peeks at the unverified `iss` and treats a token as the portal's when `iss == APP_CONFIG[:site_url]`. Five sites mint HS256 portal tokens today (`external_activity.rb`, `create_collaboration.rb`, `home_controller#authoring_site_redirect`, `api/v1/classes_controller#log_links` and `PortalTokenClaims#sign` behind `jwt_controller#portal`), and their tokens are presented back to rigse by the Activity Player, LARA, log-puller and others. `log-puller`, `te-report-prototype` and the admin-panel backend (`admin-panel/graphql-backend/src/config.ts`, via `express-jwt`) verify HS256 portal tokens with the same secret.

**What master does not have.** The Researcher Dashboard launch exists only on the RIGSE-365 spike branch (`RIGSE-365-runner-token-service`), which is a reference and is never merged. On master there is no launch action, no `RESEARCHER_DASHBOARD_URL`, no dashboard link on the Research Classes table, no `User#can_be_researcher_for_clazz?`, no report-server assertion and no `PORTAL_SERVICE_SECRET`. The researcher check exists only inline in `jwt_controller#firebase` (`rails/app/controllers/api/v1/jwt_controller.rb:230`) as `is_researcher_for_clazz? || is_project_admin_for_clazz? || has_role?('admin')`. So this story builds the launch path fresh on master rather than converting the spike's OAuth-grant launch.

**The Firebase researcher mint.** `GET /api/v1/jwt/firebase?researcher=true&class_hash=...` mints a Firebase token carrying `user_type: "researcher"` and `class_hash` for any class the caller passes the researcher check on. The dashboard app calls it with its launch token as the bearer, once per Firebase project it reads (on the spike, `report-service-dev` for results and `collaborative-learning-staging` for the live CLUE document count, `spike-plan.md` shell notes). Without a scope check, a token launched for one class mints a researcher token for every other class its holder can reach, which reads that class's answers from report-service's Firestore, where `researcherOfContext()` checks no project.

**Clauses of the Jira story set aside, and why.** Per the sprint's branching rule, a clause that deletes or renames something that exists only on the spike is ignored, because that code never reaches master. Each was checked against master:

| Jira clause | On master? | Treatment |
|---|---|---|
| Delete `Launch::PAGE = 'analyze-class'` and the `scope`, `class`, `researcher` launch parameters | No (spike only) | Set aside. The launch is built with the one `token` parameter from the start. |
| Rename `analyze_url` to `researcher_dashboard_url`, link text to "Researcher Dashboard" | No (spike only) | Set aside as a rename; the field and link are added under their final names. |
| Delete `PORTAL_SERVICE_SECRET` | No (spike only; grep of master finds nothing) | Set aside. The Done-when clause "appears nowhere in the repository" already holds on master and must stay true. |
| "the `jti` rigse already sets" | No (spike only) | The `report-server` assertion sets a `jti` as new code. |
| rigse stops holding `REPORT_SERVICE_BEARER_TOKEN` | **Yes**, but not for the reason the story gives | Restated: rigse keeps it for student feedback metadata and uses it on no dashboard path (R23). |

**`REPORT_SERVICE_BEARER_TOKEN` on master.** `final-design.md` section 11.1 says rigse holds the function app's shared bearer in order to ask for a VM, and that the assertion replaces it for `run_package`. On master, `run_package` does not exist; the token's one use is `API::V1::StudentsController#get_feedback_metadata` (`rails/app/controllers/api/v1/students_controller.rb:222`), which calls the function app's `GET /student_feedback_metadata`. That route sits behind the same shared `bearerTokenAuth` (`report-service/functions/src/index.ts:85`), and the student offerings page calls it on every load (`rails/app/views/shared/_offerings_for_student.html.haml:19`) to show the "teacher left feedback" notice. The token is also configured in `docker-compose.yml:143`, both task definitions in `configs/cloudformation/stack_template.yml` (547, 778) and the README. So the story's clause and its Done-when ("rigse's configuration holds no bearer for the function app") cannot both be met without breaking an unrelated student feature. This use was known during the spike (`spike-plan.md`, the run path's authentication decision of 2026-09-18, cites `students_controller.rb:222-250` as the reason `run_package` could reuse the bearer), but `review-resolutions.md` decision 27, which introduced "rigse stops holding it", reasons only about the VM request and does not address it.

## Requirements

### The signing key

- R1. rigse signs RS256 tokens with a private key supplied per environment through configuration (environment variables, following the `JWT_HMAC_SECRET` pattern in `docker-compose.yml` and both ECS task definitions), together with the key's `kid`. The private key exists only in rigse's configuration and is never committed, logged or returned by any endpoint.
- R2. rigse verifies RS256 tokens against a set of public keys keyed by `kid`: the current key's, plus any previous keys configured for a rotation. The verification key is selected by `kid` and the algorithm is pinned to RS256. A token whose `kid` is absent or unrecognized is refused, never verified against a default key.
- R3. The verification key is never chosen by reading `alg` from the token. An HS256 token signed with an RS256 public key as the HMAC secret is refused wherever rigse accepts RS256 tokens. Every RS256 verification passes the public key as an `OpenSSL::PKey` object, never as a PEM string, and names exactly one algorithm, since the `jwt` gem accepts that forged token when the key is a PEM string and the algorithm list includes HS256 (see Verification).
- R4. Staging and production use different keypairs. A token signed with another environment's key is refused, including when it carries the same `kid`.
- R5. There is a documented way for an operator to obtain the current environment's public key as a PEM together with its `kid`. That pair is the contract REPORT-141's verifiers accept: report-server and the report-service function are each configured with the PEM under its `kid`. rigse adds no JWKS or other public-key endpoint.
- R6. When the signing key is not configured, the dashboard launch is unavailable (R14) and nothing else in the portal changes. No existing HS256 path depends on the new key.

### Audiences and claims

- R7. rigse mints three kinds of RS256 token, each with a distinct `aud`:

  | `aud` | Claims | Lifetime |
  |---|---|---|
  | `researcher-dashboard` | `iss`, `uid`, `user_type: "researcher"`, `scope_kind`, `scope_id`, `iat`, `exp`, and `kid` in the header | see R16 |
  | `report-server` | the above plus `is_admin`, `is_project_admin`, `is_project_researcher`, the identity fields report-server's user row requires (`portal_user_id`, `portal_server`, `login`, `first_name`, `last_name`, `email`), and a unique `jti` | 2 minutes |
  | `report-service-functions` | `iss`, `uid`, `iat`, `exp`, and `kid` in the header | 2 minutes |

- R7a. Each RS256 token carries exactly one `aud`, as a string. The `jwt` gem accepts an `aud` array that contains the expected audience, so a multi-audience token would pass more than one check; rigse never mints one.
- R8. `iss` on every RS256 token is `APP_CONFIG[:site_url]`, the portal's site URL, exactly as the HS256 tokens carry it today, so that it doubles as `platform_id`.
- R9. The launch token (`aud: researcher-dashboard`) never carries the role flags or any other permission. `scope_kind` and `scope_id` record what was opened and are never treated as authorization: every endpoint that uses them also runs `can_be_researcher_for_clazz?` on the scope. A `researcher-dashboard` token missing either claim is refused wherever it is presented, so an unscoped launch token can never pass a scope check as a caller with no scope.
- R10. Verification of an RS256 token takes the expected audience from the call site. A token with a missing `aud`, or an `aud` other than the one the call site accepts, is refused. The call sites are the two places rigse decodes a portal token today, `JwtBearerTokenAuthenticatable#authenticate!` and `API::APIController#check_for_auth_token`, and any added by this story; each names the audience it accepts.
- R11. No rigse endpoint accepts a `report-server` or `report-service-functions` token as a bearer. Those two are minted for other services only.
- R11a. rigse accepts a `researcher-dashboard` token as a bearer only on `GET /api/v1/jwt/firebase` with `researcher=true` (R19) and on the `/api/v1/researcher_dashboard/*` endpoints RIGSE-368 adds. Everywhere else, including `POST`/`GET /api/v1/jwt/portal`, `jwt/firebase` without `researcher=true`, and every controller that authenticates through the Devise strategy, such a token authenticates no one.
- R12. HS256 portal tokens keep working exactly as today: the five existing minting sites keep minting HS256 with `JWT_HMAC_SECRET`, and rigse keeps accepting them from the runtimes that present them. `JWT_HMAC_SECRET` stays, and no new code in this story signs or verifies with it.

### The launch

- R13. `User#can_be_researcher_for_clazz?(clazz)` is the single definition of the researcher gate: a project researcher for the class, a project admin for the class, or a site admin. `jwt_controller#firebase`'s inline check uses it, with unchanged behavior.
- R14. The dashboard is **enabled** in an environment when both `RESEARCHER_DASHBOARD_URL` and the signing key are configured, and disabled otherwise. `GET /portal/classes/:id/researcher_dashboard` exists. A visitor who fails `can_be_researcher_for_clazz?` gets the portal's standard not-authorized handling (sign-in redirect for an anonymous visitor, the not-authorized response otherwise) and no token is minted. When the dashboard is disabled the action answers 404 and mints nothing.
- R15. For an authorized researcher, the action mints a `researcher-dashboard` token with `scope_kind: "class"` and `scope_id` set to the class's portal id as an integer, and redirects to `RESEARCHER_DASHBOARD_URL` with `token=<jwt>` as the only parameter rigse adds to it.
- R16. The launch token lives 2 hours, matching the class dashboard's `ExternalReport::ReportTokenValidFor`, held in one named constant. An expired launch token is refused at every rigse call site that accepts it.
- R17. `GET /api/v1/research_classes` rows carry `researcher_dashboard_url`, which links to R14's action. It is present only when the dashboard is enabled (R14) and the current user passes `can_be_researcher_for_clazz?` for that class, and absent otherwise.
- R18. The Research Classes table (`researcher-classes-form/table.tsx`) shows a "Researcher Dashboard" link beside "View Roster" when the row carries `researcher_dashboard_url`.

### The Firebase researcher mint

- R19. `GET /api/v1/jwt/firebase?researcher=true&class_hash=...` presented with a bearer that carries `scope_kind` and `scope_id` refuses any `class_hash` whose class is not the scope, and refuses a `scope_kind` it does not recognize, with the endpoint's existing refusal (a 400 carrying a message, as its other researcher refusals answer today through `rescue_from StandardError`). `can_be_researcher_for_clazz?` still runs for the matching class.
- R20. Callers whose bearer carries no scope, which is every current consumer of the endpoint, get exactly today's behavior.

### Configuration and secrets

- R21. `RESEARCHER_DASHBOARD_URL`, the signing key and its `kid` are added to `docker-compose.yml`, both task definitions and the parameters of `configs/cloudformation/stack_template.yml`, and the local setup documentation, without defaults that put a key in the repository.
- R22. `PORTAL_SERVICE_SECRET` appears in no code or configuration in the repository (`git grep PORTAL_SERVICE_SECRET -- ':!specs'` returns nothing); the specs name it only to record why the Jira clause deleting it was set aside.
- R23. `REPORT_SERVICE_BEARER_TOKEN` stays, for `get_feedback_metadata` only. No dashboard path in this story or RIGSE-368 uses it, so the Jira Done-when "rigse's configuration holds no bearer for the function app" is met in the form "rigse uses the function app's shared bearer on no dashboard path". Moving feedback metadata onto an assertion is a possible follow-up story, not part of this one.

## Technical Notes

- **Files on master this story touches**: `rails/lib/signed_jwt.rb`, `rails/lib/jwt_bearer_token_authenticatable.rb`, `rails/app/controllers/api/api_controller.rb`, `rails/app/controllers/api/v1/jwt_controller.rb`, `rails/app/models/user.rb`, `rails/app/controllers/portal/clazzes_controller.rb`, `rails/app/controllers/api/v1/research_classes_controller.rb`, `rails/react-components/src/library/components/researcher-classes-form/table.tsx`, `rails/config/routes.rb`, `docker-compose.yml`, `configs/cloudformation/stack_template.yml`, `README.md`, and specs under `rails/spec/libs`, `rails/spec/controllers`, `rails/spec/models`.
- **Routing RS256 versus HS256.** `SignedJwt.portal_token?` routes by the unverified `iss`, and RS256 tokens carry the same `iss` (R8), so both kinds arrive at the portal-token path. Separating them must not let the token's `alg` choose the key (R3). Distinguishing by the presence of a `kid` header, or by the header `alg` where each branch pins its own algorithm and its own key, are both safe, because the confusion attack needs a verifier that hands the RS256 public key to an HMAC check; the implementation spec picks one.
- **The researcher gate.** The spike extracted `can_be_researcher_for_clazz?` into `User` (`rails/app/models/user.rb` on the spike branch); master's predicate is the inline three-way check in `jwt_controller#firebase`. `is_researcher_for_clazz?` filters out expired researcher grants (`researcher_for_projects`).
- **The launch action's pattern.** `Portal::ClazzesController#external_report` (`rails/app/controllers/portal/clazzes_controller.rb:365`) is the existing authorize-mint-redirect shape; its not-authorized path goes through `ApplicationController#pundit_user_not_authorized`. The spike gated the dashboard on `ENV['RESEARCHER_DASHBOARD_URL'].present?`, following the portal's existing gate on `REPORT_SERVER_REPORTS_URL` in `navigation_helper.rb`.
- **The app's expiry handling.** The spike app (`researcher-dashboard/app/src/shell/portal.ts:38`) treats a 401 or 403 from rigse as an expired launch and shows "This link has expired. Launch the dashboard again from the portal" (`Info.tsx`). So an expired launch token already has a researcher-facing answer, and the lifetime is a trade between exposure and relaunch frequency.
- **Comparable lifetime.** The class dashboard's OAuth grant uses `ExternalReport::ReportTokenValidFor = 2.hours` (`rails/app/models/external_report.rb:12`).
- **The report-server assertion's shape.** The spike's assertion carried report-server's `PortalUserInfo` struct (`portal_user_id`, `portal_server`, `login`, `first_name`, `last_name`, `email` and the three flags), signed HS256 with `PORTAL_SERVICE_SECRET`, with `iss` set to the site host rather than the site URL. REPORT-141 owns report-server's verification and its reading of the claims.
- **The jwt gem** is `jwt 2.10.1` (`rails/Gemfile.lock:319`).
- **Key configuration shape.** A PEM private key is multi-line, while the stack passes secrets as plain CloudFormation parameters into ECS environment values (`JWT_HMAC_SECRET` at `stack_template.yml:476`), and a rotation needs a previous public key configured beside the current one. How the key and its `kid` are encoded is the implementation spec's decision.
- **Consumers of the new public key** are report-server and the report-service function (REPORT-141), configured by value keyed by `kid`.

## Verification

Stage 4 ran throwaway probes (deleted, never committed) against `jwt 2.10.1` on the portal image's Ruby 3.3.1, to check the load-bearing assumptions before the implementation spec:

| Case | Result |
|---|---|
| RS256 token, expected `aud` | accepted |
| RS256 token, wrong `aud` / missing `aud` with `verify_aud` | refused (`InvalidAudError`) |
| `aud` array containing the expected value | **accepted**, hence R7a |
| HS256 token signed with the public key's PEM, verifier pinned to RS256 with an `OpenSSL::PKey` | refused (`IncorrectAlgorithm`) |
| Same token, verifier given `algorithms: [RS256, HS256]` and an `OpenSSL::PKey` | refused (`HMAC key expected to be a String`) |
| Same token, verifier given `algorithms: [RS256, HS256]` and the **PEM string** | **accepted**, hence R3's constraint on how the key is passed |
| Token signed by another environment's key under the same `kid` | refused (`VerificationError`) |
| `kid` selected through the decode block, known / unknown / absent | accepted / refused / refused |
| PEM private key stored `\n`-escaped in one environment value | parses |

A second probe routed tokens by the presence of a `kid` header (RS256 key set, pinned, when present; `JWT_HMAC_SECRET`, pinned HS256, when absent), which is one of the two safe routings named in Technical Notes. Every case behaved: legacy HS256 accepted; RS256 launch token accepted; a `report-server` token at a rigse call site refused; an HS256 token carrying a `kid` and signed with the public PEM refused; an RS256 token without a `kid` refused; an HS256 token without a `kid` signed with the public PEM refused; `alg: none` with and without a `kid` refused.

## Out of Scope

- A JWKS endpoint (the later step, when `log-puller` and `te-report-prototype` migrate off `JWT_HMAC_SECRET`).
- Migrating any existing HS256 consumer, or any of the five existing minting sites, to RS256.
- The dashboard API (`GET /api/v1/researcher_dashboard/classes/:id`, `refresh_profile`, `run_package`), and anything that sends the `report-server` or `report-service-functions` token to another service: RIGSE-368.
- Verification of rigse's tokens in report-server and the function, the `jti` nonce cache and `api_tokens.expires_at`: REPORT-141.
- The app's handling of the launch token, and the info page for `page=analyze-class`: RD-3.
- Any compatibility shim for the spike's `page=analyze-class` launch.
- Deleting spike-only code (see the set-aside clauses in Background).

## Open Questions

### RESOLVED: Judgment call: are HS256 portal tokens subject to the audience rule?
**Context**: The story says "a token with a missing or wrong `aud` is refused at every rigse call site". Every HS256 portal token in circulation carries no `aud`, and the Activity Player, LARA, log-puller and others present them to rigse.
**Options considered**:
- A) The audience rule applies to RS256 tokens, the only ones that carry more than one audience; HS256 tokens are verified exactly as today.
- B) HS256 tokens also gain an `aud` and a missing one is refused, breaking every token issued before the deploy and any HS256 token minted outside rigse by a holder of `JWT_HMAC_SECRET`.

**Decision**: A. The audience check exists to keep the three RS256 uses apart (`final-design.md` 11.1: "that is the difference between three credentials and one"); an HS256 token has one use, and anyone holding `JWT_HMAC_SECRET` can forge any `aud` anyway, so adding one buys nothing and breaks live runtimes. Recorded as R10 and R12.

### RESOLVED: Judgment call: does this story mint the `report-server` and `report-service-functions` tokens, which nothing on master sends yet?
**Context**: Their first caller is RIGSE-368's run path.
**Options considered**:
- A) This story adds the minting for all three audiences, with specs, and RIGSE-368 only calls it.
- B) This story mints only the launch token and RIGSE-368 adds the other two.

**Decision**: A. The story defines all three claim sets on the one key, and REPORT-141, the next wave, needs real tokens of both service audiences from rigse to test its verification against. Recorded as R7.

### RESOLVED: Judgment call: build the launch fresh rather than convert the spike's launch
**Context**: The story describes the launch as a change to an existing action (`Launch::PAGE` deleted, `analyze_url` renamed).
**Options considered**:
- A) Build the route, action, row field and link on master under their final names.
- B) Port the spike's OAuth-grant launch and then convert it.

**Decision**: A, required by the branching rule: story branches never carry spike code, and clauses that remove spike-only code are set aside.

### RESOLVED: `REPORT_SERVICE_BEARER_TOKEN` is used on master by student feedback metadata, not by `run_package`
**Context**: The story and `final-design.md` say rigse stops holding the function app's shared bearer, on the understanding that rigse holds it to ask for a VM. On master it is the credential for `GET /student_feedback_metadata`, which the student offerings page calls to show the teacher-feedback notice. Removing it breaks that notice in every environment.
**Options considered**:
- A) Keep `REPORT_SERVICE_BEARER_TOKEN` for feedback metadata. This story (and RIGSE-368) never use it for anything dashboard-related; the Done-when clause is restated as "rigse uses no bearer for the function app on any dashboard path".
- B) Remove it from rigse, and have report-service accept an `aud: report-service-functions` assertion on `/student_feedback_metadata` as well (a change to REPORT-141's scope, and a second route on that audience).
- C) Remove it and drop the feedback notice.

**Recommendation**: A. It is the only option that keeps a live student feature working without widening another story, and it keeps what the story is actually protecting: no dashboard path gives rigse a credential that opens `move_student_work` or the importers. B is the complete fix but moves a second route onto the `report-service-functions` audience in REPORT-141 and changes the student page's dependency; it is a reasonable follow-up story rather than a precondition.

**Decision**: A (Doug, 2026-09-23). Keep it for feedback metadata; the Done-when clause is restated as no dashboard path using it. Recorded as R23.

### RESOLVED: Where does rigse accept the launch token?
**Context**: rigse's Devise strategy authenticates any valid portal token for every controller. If a `researcher-dashboard` token is accepted everywhere, the app's bearer is a full rigse API credential for the researcher, and `POST /api/v1/jwt/portal` would exchange it for a one-hour HS256 portal token with admin claims and no scope, undoing both the audience and the scope. The app's only rigse calls are `jwt/firebase` and RIGSE-368's `researcher_dashboard` endpoints.
**Options considered**:
- A) Accept `researcher-dashboard` tokens only on `jwt/firebase` (researcher branch, R19) and on the endpoints RIGSE-368 adds; refuse them everywhere else, including `jwt/portal` and `jwt/firebase`'s non-researcher branches.
- B) Accept them everywhere a portal token is accepted, as `final-design.md` 11.1's "whose API already accepts a portal JWT bearer" reads, and refuse only at `jwt/portal`.
- C) Accept them everywhere.

**Decision**: A. The spike app's only rigse calls are `/api/v1/researcher_dashboard/classes/:id`, `/api/v1/researcher_dashboard/run_package` and `/api/v1/jwt/firebase?researcher=true` (`researcher-dashboard/app/src/shell/portal.ts:58,69,85`), and `final-design.md` section 4 adds only `refresh_profile` under the same namespace, so the narrow rule breaks no consumer while closing the `jwt/portal` exchange, which would otherwise turn a scoped, audience-bound token into an unscoped one-hour HS256 bearer with admin claims. Recorded as R11a.

### RESOLVED: Low confidence: how long does the launch token live?
**Context**: `final-design.md` says "short, and it expires by its own claim", and the app keeps it as its bearer for the whole session, re-minting its Firebase token hourly with it. Too short and a researcher is sent back to the portal mid-session; too long and a pasted launch URL stays live.
**Options considered**:
- A) 2 hours, matching the class dashboard's `ExternalReport::ReportTokenValidFor`.
- B) 1 hour, matching `PortalTokenClaims::STANDARD_TTL`.
- C) 8 hours, matching the VM's maximum life.

**Decision**: A, 2 hours. The token is needed less than it looked: the app signs into each Firebase project once with the custom token rigse mints (`shell/firebase.ts:85`), and the Firebase SDK refreshes its own ID token from then on, so the result and status listeners keep working after the launch token expires; only new rigse calls (run, refresh, metadata) need it. Two hours matches what researchers already experience with the class dashboard's grant, and the app already has a relaunch page for an expired bearer (`Info.tsx`). A constant, so changing it later is a one-line change. Recorded as R16.

### RESOLVED: Low confidence: the `report-server` assertion's claim set
**Context**: The story gives it as the launch token's claims plus the three role flags. report-server's existing mint endpoint, as the spike called it, reads its `PortalUserInfo` struct (`portal_user_id`, `portal_server`, `login`, `first_name`, `last_name`, `email`, flags). Whichever shape rigse signs is the contract REPORT-141 verifies.
**Options considered**:
- A) Exactly the story's list: `iss`, `uid`, `user_type`, `scope_kind`, `scope_id`, `exp`, `kid`, the three flags and `jti`.
- B) The story's list plus the `PortalUserInfo` identity fields report-server needs to create or update its user row.

**Decision**: B. report-server mints against a user row it finds or creates from `PortalUserInfo` (`report-service/server/lib/report_server/accounts.ex:16`), its `User` changeset runs `validate_required` over every portal field including `portal_login` and `portal_email` (`accounts/user.ex:30`), and it names the researcher's Athena workgroup from `portal_email` (`athena_db.ex:104`). An assertion without those fields cannot create a first-time researcher's row. They cost nothing in exposure, since this assertion travels service to service and never reaches a browser, and the launch token stays minimal. REPORT-141 reads `portal_user_id` and `portal_server` as the spike's controller does; `uid` and `iss` carry the same facts in the shared claim shape. Recorded as R7.

## Self-Review

Roles: Security Engineer, Senior Rails Engineer, QA Engineer, DevOps Engineer, Product Manager. Each finding below was checked against the code before being recorded; candidates that did not survive (CSRF on the GET launch action, which redirects only to the configured URL as `external_report` does; masquerade, where the token names the switched-to user exactly as every other launch does; Referer leakage of the token from the app's page, which is the app's and its stack's concern in RD-3 and RD-1; and whether the worker task needs the key, which it does not use but receives by the stack's convention of giving both task definitions the same environment) were dropped.

### Senior Rails Engineer

#### RESOLVED: "Configured" was undefined and the unconfigured launch was untestable
R14 said the action "does not redirect anywhere" when unconfigured, and R17 hid the link "when the dashboard is configured", without saying whether the signing key counts. The spike gated on `RESEARCHER_DASHBOARD_URL` alone (`researcher_dashboard.rb` on the spike), which here would offer a link whose action cannot mint. Fixed: R14 defines "enabled" as both the URL and the key configured, the action answers 404 when disabled, and R17 uses the same definition.

#### RESOLVED: `scope_id`'s type was unstated
The app builds `/api/v1/researcher_dashboard/classes/${classId}` from it and RIGSE-368 and report-server compare it, so a string in one place and an integer in another is a silent mismatch. Fixed: R15 says the class's portal id as an integer.

### QA Engineer

#### RESOLVED: "Refused at every rigse call site" named no call sites
The Done-when clause cannot be tested without the list. A grep of master finds exactly two decoders of portal tokens, the Devise strategy (`jwt_bearer_token_authenticatable.rb:9`) and `check_for_auth_token` (`api_controller.rb:34`). Fixed: R10 names them.

#### RESOLVED: The `jwt/firebase` scope refusal had no stated response
R19 said "refuses" without a status, and the endpoint's refusals all answer 400 through `rescue_from StandardError, with: :error_400` (`jwt_controller.rb:10`), including the existing "You do not have access to the requested class_hash as a researcher". Fixed: R19 uses the same refusal, so a spec can assert it and existing clients see one shape.

