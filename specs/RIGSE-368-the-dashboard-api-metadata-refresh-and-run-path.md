# RIGSE-368: The dashboard API: scope metadata, the profile refresh and the run path

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-368

**Status**: **Closed**

## Overview

rigse gains the three endpoints the Researcher Dashboard app calls with its launch token: one describing the class it was launched into, one asking report-service to rebuild the class's authored URL profile, and one queueing a batch of packages to run. All three check that the researcher may open the class on every call, and the run path answers as soon as report-service has accepted the work instead of waiting for a VM.

## Changed by the RIGSE-367 redesign

**Read this section first; it overrides the requirements below where they disagree** (2026-09-28). RIGSE-367 was redesigned after scytacki's review of PR #1487 and re-implemented on `RIGSE-367-oauth-pkce-scoped-tokens` from `master` (spec `specs/RIGSE-367-oauth-pkce-launch-and-scoped-tokens/` on that branch). This branch stacks on #1487's `RIGSE-367-portal-signing-key`, which the redesign replaces, so it is rebased onto the new branch and reworked before it merges. What changes:

- **The credential (R1, R2, R3).** There is no `aud: researcher-dashboard` launch token. The app gets an RS256 access token (RFC 9068, header `typ: at+jwt`) from `/oauth/token` by the authorization code flow with PKCE, carrying `scope` (space-separated capabilities) and `context: {"type": "class", "id": <integer>}` in place of `scope_kind`/`scope_id`. The three endpoints authenticate through `current_user` (the Devise JWT strategy accepts the access token and stores no session for it) and authorize with Pundit or the researcher gate, not through `check_for_auth_token(params, aud: ...)`, which the redesign removed the `aud:` keyword from. Each declares what it accepts with `accepts_token_capability`: the metadata and `refresh_profile` endpoints `class:researcher-read`, `run_package` `class:researcher-run` (capabilities are flat: neither implies the other, and the dashboard's client is configured with both). Each checks the class it touches with `require_token_capability!(capability, clazz)`, which is the class in the token's `context`, and still runs `can_be_researcher_for_clazz?`. `Current.token_scope_kind`/`token_scope_id` do not exist; `Current.token_scope` and `Current.token_context` do. A scoped token is refused everywhere that declares none of its capabilities by one global check, so "accept only the launch token" (the "endpoints accept only a launch token" decision) becomes "declare the capability"; an unscoped session or HS256 token is a full-user credential on these endpoints unless the controller also declares no `portal-api` (`API::APIController` accepts `portal-api` by default; this controller should `accepts_no_token_capabilities` first, then declare its two). R7's `platform_user_id` is `current_user`, not the token's `uid` read by hand: the two are the same user on every call the app makes, and differ only for a same-origin request that also carries a portal session, which Warden authenticates in preference to the bearer.
- **The routes (R4, R7, R11, R16).** The three endpoints name no class. They are `GET /api/v1/researcher_dashboard/scope`, `POST /api/v1/researcher_dashboard/refresh_profile` and `POST /api/v1/researcher_dashboard/run_package`, and each acts on the class in the token's `context` claim. The metadata body gains `kind` beside the class fields, matching `scope.json`'s `kind`, `id` and `classes`. With no path id there is nothing to compare with the scope, so R4's comparison and `require_path_matches_scope` go away: `require_token_capability!(capability, clazz)` checks the capability against the token's own context and `can_be_researcher_for_clazz?` checks access. A second scope kind, most plausibly a cohort, then costs a `TokenCapabilities` registry entry and a method expanding a context into its classes rather than a second set of routes (Decisions).
- **Refusing an unscoped credential (R1).** `TokenScope.allows?` passes any credential that carries no scope, so the controller refuses one itself with a 401 before any capability check. These are CSRF-exempt bearer endpoints that mint Firebase runner tokens, and a portal session reaching them would be a forgery hole.
- **Enabling (R5).** `RESEARCHER_DASHBOARD_URL` and `ResearcherDashboard.enabled?` are gone: the dashboard is an `ExternalReport` plus a public `Client` with scopes, created by an admin. There is no longer a portal-wide "disabled" state and so no blanket 404; the only thing left to be missing is a setting an endpoint needs (the signing key via `PortalSigningKey.usable?`, `REPORT_SERVER_URL`, the function URL, the Firebase apps), which R5's second half already covers as a 503 naming it.
- **The resolve bearer (R17).** rigse forwards the app's access token to report-server's resolve. That token's `aud` is a list naming rigse (`site_url`) and report-server (`REPORT_SERVER_URL` without a trailing slash); report-server's catalog pipeline accepts it once REPORT-142's verifier checks list membership and `packages:read`.
- **The assertions (R13, R21).** `ResearcherDashboard::Assertions` is now `PortalAssertions` (`app/services/portal_assertions.rb`), built on `SignedJwt.create_assertion`: `report_server(user:, clazz:)` and `report_service_functions(user:)`, with the same claims and audiences, `context` in place of `scope_kind`/`scope_id`, and `user_type: "researcher"` kept. Both still carry a single-string `aud`.
- **Settings.** `REPORT_SERVER_URL` and the `ReportServerURL` stack parameter are added by RIGSE-367, under the same names this branch uses, so the rebase drops this branch's copies of them.
- **Specs.** The controller and request specs present an access token from `SignedJwt.create_access_token(user, client_id:, capabilities:, context:, audiences:, expires_in:)` in place of a launch token, and request specs that present a bearer call `Rails.application.reload_routes_unless_loaded` in `before(:all)`, since Rails 8 draws routes lazily in test and Devise registers its Warden strategies from them.

## Requirements

### Authorizing every call

- R1. All three endpoints authenticate only with a verified `aud: researcher-dashboard` launch token in the `Authorization` header, through `check_for_auth_token(params, aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)`. A request authenticated any other way (a session cookie, an HS256 portal token, an AccessGrant, a token of another audience) or with a missing, invalid or expired bearer is 401, because only a launch token carries the scope the endpoints act on.
- R2. The scope is `Current.token_scope_kind` and `Current.token_scope_id`. A `scope_kind` other than `"class"` is 403. A class that no longer exists is 404.
- R3. `can_be_researcher_for_clazz?(clazz)`, called on the user the launch token names (`uid`), runs on every call, before anything is read for the response, minted or sent anywhere, and a failure is 403. The scope is a record of the launch and never authorization on its own (RIGSE-367 R9).
- R4. On `GET /api/v1/researcher_dashboard/classes/:id` and `POST .../classes/:id/refresh_profile`, an `:id` other than the token's `scope_id` is 403, compared as integers. A non-numeric `:id` never reaches the endpoint: every `/api/v1` route sits inside the router's `constraints :id => /\d+/` block (`config/routes.rb:54`), so it is the router's 404. `run_package` takes no class id at all.
- R5. When the dashboard is disabled (`ResearcherDashboard.enabled?` false) all three answer 404, as the launch action does (RIGSE-367 R14). When it is enabled but a setting the refresh or run path needs is missing (R29), that endpoint answers 503 naming the setting and sends nothing.
- R6. `/api/v1/researcher_dashboard/*` is added to the portal's static CORS allowlist (`config/application.rb`) for `GET` and `POST`, with any request header, so the app's origin can call it with a bearer. The allowlist's `origins '*'` sends no credentials, and none of the three endpoints accepts a cookie (R1).

### The metadata endpoint

- R7. `GET /api/v1/researcher_dashboard/classes/:id` answers 200 with:
  - `id`, `name` and `class_hash` of the class;
  - `platform_user_id`, the requesting researcher's portal user id (the token's `uid`);
  - `teachers`, one `{id, name}` per teacher of the class, `id` being the teacher's user id and `name` their first and last name;
  - `cohorts`, one `{id, name}` per distinct cohort of the class's teachers;
  - `project_ids`, the distinct ids of the projects those cohorts belong to, sorted;
  - `assignment_fingerprint` (R10);
  - `assignments`, one `{offering_id, runnable_id, name, url, tool}` per assignment (R8).

  It carries no `platform` field at any level, and no runner token or other credential.
- R8. The assignments are the class's offerings whose runnable is an `ExternalActivity`, in offering `position` order, including inactive ones, since their student data exists either way. `url` is the external activity's stored URL exactly (`read_attribute(:url)`), never `ExternalActivity#url`, and may be an empty string. `name` is the external activity's name. `tool` is the external activity's tool's `name`, or null when it has none, and is for display only; nothing in rigse, report-service or the runner matches on it.
- R9. Offerings of any other `runnable_type` are skipped rather than failing the request.
- R10. `assignment_fingerprint` is `v1:` followed by the lowercase hex SHA-256 of the JSON array of `[offering_id, url]` pairs of the class's assignments (R8) sorted by offering id. It changes whenever an assignment is added or removed or an assignment's URL changes, is identical for identical lists, and is 67 characters, inside REPORT-142's 256. The same computation is what `refresh_profile` sends (R13), so an app that has just refreshed sees a matching fingerprint on the profile document.

### The profile refresh

- R11. `POST /api/v1/researcher_dashboard/classes/:id/refresh_profile` takes no body. After R1 to R4, it builds `assignment_urls` from the class's own assignments (R8): each distinct non-empty URL of at most 2,048 characters, sorted. A URL longer than that is left out, since REPORT-142 refuses it.
- R12. rigse does not fetch, parse, normalize or follow any of these URLs, and derives nothing from them. It sends the list and nothing else about the assignments.
- R13. It `POST`s `{class_hash, assignment_fingerprint, assignment_urls}` to the `researcherDashboard` function's `/derive-profile`, with a freshly minted `aud: report-service-functions` assertion as the bearer, and answers 202 `{queued: true, assignment_fingerprint}` when the function answers 202. It does not wait for the derivation.
- R14. When the list would exceed REPORT-142's limits (more than 500 URLs, or a body over 256 KiB), rigse answers 422 naming the limit and sends nothing, rather than sending a request the function would refuse.
- R15. A function answer other than 202, a connection failure or a timeout is 502 (504 for a timeout) carrying the function's status and reason (R28).

### The run path

- R16. `POST /api/v1/researcher_dashboard/run_package` takes a JSON body of exactly `{"packages": [{"identity": "...", "version": "..."}]}`, checked against the request body as parsed JSON rather than against Rails `params`, which also carry routing keys and the parameter wrapper's copy. It is 400 with a message naming the problem, and nothing is resolved, minted or sent, when:
  - the body is not a JSON object;
  - the body has any top-level key other than `packages`, or `packages` is not a non-empty array of at most 20 entries;
  - an entry has any key other than `identity` and `version`, which is how a `checksum`, `package_key`, `catalog_id` or scope field supplied by the caller is refused rather than ignored;
  - an `identity` does not match `^(users|projects)/[0-9]+/[a-z0-9][a-z0-9-]{0,62}$`, or a `version` does not match `^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$` (REPORT-142 R3 and R7);
  - two entries name the same identity, since a result document is keyed by identity and one batch cannot queue two versions of one package for one class.
- R17. rigse resolves every package in the batch against report-server's `GET /api/v1/packages/resolve`, presenting the launch token the app sent it as the bearer and no `Origin` header, before it mints or sends anything. The checksum and catalog id come only from the resolve answer, and so does whether the version declares `clue_prepull`.
- R18. If any package fails to resolve, the whole request is refused and nothing is minted or sent, so a five-package request queues five or none:
  - resolve 404 is 409 naming the package and saying it cannot be resolved (it does not exist or the researcher may not see it);
  - `runnable: false` is 409 naming the package and carrying report-server's `reason` (`archived`, or not official while unreviewed runs are off);
  - any other answer, a resolve body that does not echo the requested identity and version or lacks a `sha256:` checksum or a positive integer `catalog_id`, a connection failure or a timeout is 502 (504 for a timeout) carrying report-server's status and reason (R28).
- R19. rigse mints, for the one class in the scope:
  - one **session runner token** in the report-service Firebase project (R29), carrying the researcher's identity claims, `user_type: "researcher"` and `researcher_dashboard_runner: true`, and no `class_hash`;
  - one **class runner token** per Firebase project the packages read, each carrying the same claims plus the class's `class_hash`, keyed in `class_tokens` by the FirebaseApp name that signed it. The report-service project always gets one, since the runner writes the class's result documents with it; the CLUE project (R29) gets one when any package in the batch declares `clue_prepull` (R20).

  Both use the uid and identity claims `jwt/firebase` issues the same user today, so the VM and the app name one Firebase principal, and each lives the one hour a Firebase custom token allows.
- R20. rigse mints the CLUE class token whenever a package declares `clue_prepull`, whatever the runner is configured to do with it, and never reads the runner's configuration (section 13).
- R21. rigse signs a fresh `aud: report-service-functions` assertion as the bearer and a fresh `aud: report-server` assertion for `report_server_assertion` on every call. Signing an assertion is not minting a report-server token: the function exchanges it only on the branch that launches a VM (REPORT-141 R17), so the reuse branch leaves the running VM's token alone.
- R22. rigse `POST`s to the `researcherDashboard` function's `/run-package`:

  ```json
  {
    "packages": [{ "identity": "...", "version": "...", "checksum": "sha256:...", "catalog_id": 12 }],
    "scope": {
      "kind": "class",
      "collection": "classes",
      "id": "<class_hash>",
      "classes": [{ "class_hash": "<class_hash>", "class_id": 111 }],
      "assignments": [{ "offering_id": 9, "runnable_id": 1234, "name": "Moth 1.2", "url": "https://..." }]
    },
    "class_tokens": { "<report-service FirebaseApp>": "...", "<CLUE FirebaseApp>": "..." },
    "session_token": "...",
    "firebase_project": "<report-service FirebaseApp>",
    "report_server_assertion": "..."
  }
  ```

  `packages` is in the order the caller sent. `assignments` is exactly the metadata endpoint's list (R8) without `tool`. `firebase_project` is the report-service FirebaseApp name, which is its Firebase project id.
- R23. When the function answers 202, rigse answers 202 with the function's `queue`, `appended` and `vm` and nothing else from its body, on both the launch and the reuse branch. When the function answers 409, rigse answers 409 carrying its reason. Any other answer is 502 carrying the function's status and reason (R28).
- R24. No runner token, class token, session token or assertion appears in any response body, error message or log line rigse writes. Upstream bodies are read only for their reason, and only after the request's own tokens have been sent.
- R25. Nothing about a run is stored in rigse. Two researchers running the same package on the same class at the same moment make two independent calls, each carrying its own researcher's assertions, and each is answered by its own function response.
- R26. Nothing in rigse waits for a VM. The only outbound calls are the resolves and the one `/run-package` (or `/derive-profile`) request, each with its own open and read timeouts.
- R27. A timeout or connection failure on any outbound call is rescued and answered as R15, R18 and R23 say, never surfacing as an unhandled exception or a Rails 500. A timeout on `/run-package` says the work may already be queued, since REPORT-141 writes the queue before it touches a VM.

### Errors and configuration

- R28. Every refusal uses `API::APIController#error`, so the body is `{success: false, response_type: "ERROR", message, details}`. The `message` names what failed in words the page can show. For a refusal caused by report-server or the function, `details` carries `{upstream, status, reason}`, where `reason` is the upstream's own message (the function's, or report-server's `message`/`error`, or its `reason` for `runnable: false`), truncated to a bounded length, so no launch failure is reported as a bare status code.
- R29. Four settings, read from the environment and documented beside the RIGSE-367 ones in `docker-compose.yml`, both task definitions and the parameters of `configs/cloudformation/stack_template.yml`, and the README, with no defaults that point a real environment at another's services:
  - `REPORT_SERVER_URL`, the report-server API base URL, for the resolve;
  - `RESEARCHER_DASHBOARD_FUNCTION_URL`, the `researcherDashboard` function's URL, for `/run-package` and `/derive-profile`;
  - `RESEARCHER_DASHBOARD_FIREBASE_APP`, the report-service FirebaseApp name, which is also `firebase_project`;
  - `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`, the CLUE FirebaseApp name, which RIGSE-369 deletes.

  `REPORT_SERVICE_URL` and `REPORT_SERVICE_BEARER_TOKEN` are not used by any dashboard path (RIGSE-367 R23).
- R30. Every refusal, timeout or connection failure from report-server or the function writes one warning to the portal log naming the upstream, its status and its reason, so a failed run a researcher reports can be found server-side. No request or response body is logged, so no token reaches the log (R24) (Doug, 2026-09-24, from the implementation review).

## Technical Notes

- **What master had before this story.** None of the dashboard API: no `API::V1::ResearcherDashboardController`, no `/api/v1/researcher_dashboard` route and no CORS entry for it; the spike's metadata endpoint (`RIGSE-365-runner-token-service`) was never merged, so everything here was built fresh on the RIGSE-367 branch, which this story stacks on and whose primitives it uses: the Devise JWT strategy's acceptance of the access token, `TokenScope` and `Current.token_scope`/`token_context`, `TokenCapabilityCheck`'s `accepts_token_capability` and `require_token_capability!`, `User#can_be_researcher_for_clazz?` and `PortalAssertions`.
- **Portal facts the endpoints rest on.** `ExternalActivity#url` re-serializes the stored value (lowercasing the scheme, dropping a default port), so the stored `read_attribute(:url)` is what the endpoints report; it can be `""`, and an activity's name can be null. An offering whose `runnable_type` names a model that no longer exists raises `NameError` when loaded, so only `ExternalActivity` offerings are read. `tools.name` is the display name; `source_type` is what the portal branches on. The projects a class belongs to are the projects of its teachers' cohorts, the same join the researcher gate makes. `class_hash` is 48 lowercase hex.
- **The other ends of its calls.** report-service's `researcherDashboard` function (REPORT-141) takes `/run-package` behind an `aud: report-service-functions` bearer, validates the whole batch before writing, and answers 202 `{success: true, queue: [{class_hash, package_key}], appended: [package_key], vm}`, 400 naming a field, 401, 409 `queue at its cap (N outstanding)`, 502 for an upstream failure after queueing, 500, or 503 naming its unset launch settings; every error body is `{success: false, error}`, and each of its upstream calls is made once with a 10-second timeout. The same function (REPORT-142) takes `/derive-profile` with `{class_hash, assignment_fingerprint, assignment_urls}` (at most 500 URLs of at most 2,048 characters, 256 KiB in all), answering 202 `{success: true, queued: true}`, 400, 502, or 503 while `RD_AUTHORING_HOSTS` is empty. report-server's `GET /api/v1/packages/resolve?identity=&version=` (REPORT-142) takes the app's launch token and answers `{catalog_id, identity, version, checksum, expected_duration_seconds, clue_prepull, archived, runnable, reason}`, 404 for a package the caller may not see, 401 without a launch token or for an unknown `uid`, and 503 when its portal read times out, with errors as `{error: CODE, message}`.
- **Set-aside Jira clauses.** The story's rename of `platform` to `tool` and its deletion of the spike's wait (`waitUntilRunning`, the 30-second-against-180-second timeout, the unrescued `Net::ReadTimeout`) act on spike-only code, so they were set aside as a rename and a deletion and restated as requirements on the new code: the endpoint never has `platform` (R7), and the run path never waits and rescues its own timeouts (R26, R27).
- **Runner claim.** `researcher_dashboard_runner: true` is the claim report-service's rules and CLUE's deny-write rules key on; the spike's `RunnerToken` was the reference shape.
- **Firebase custom tokens live at most one hour**, and the class tokens sit in `work/{uid}` until the VM takes the work, so a package queued behind more than an hour of other work reaches the VM with an expired custom token; that is RD-4's and REPORT-143's concern, since rigse can mint only at request time.
- **report-server reads the caller's grants from the portal on every resolve**, so resolves run one at a time and stop at the first refusal.
- **The `work/` document holds the scope block**, including the assignments, under Firestore's 1 MiB document cap, which REPORT-141 owns.
- **Where the other halves are specified**: the function's validation, queue and VM branch (REPORT-141), the resolve and the deriver (REPORT-142), `/work` and the rules (REPORT-143), the runner (RD-4), the app's use of all three endpoints (RD-3), and the deletion of the CLUE mint (RIGSE-369).

### As built

Where the code departs from the implementation plan, and how it was verified.

- **The controller skips `verify_authenticity_token`** (step 3), as `jwt_controller` and the other bearer-only `/api/v1` controllers do. The plan relied on `protect_from_forgery`'s null session, which lets a bearer request through but logs a CSRF warning on every POST; the endpoints read no session (R1), so skipping the check changes nothing but the noise.
- **The spec harness is a shared context** (step 3), `with the researcher dashboard configured` in `rails/spec/support/researcher_dashboard_helper.rb`, rather than an `around` hook written into each spec file, since the controller spec and three service specs all need it. It sets and restores the variables the same way.
- **The controller spec calls `Current.reset` before each example** (step 3), so a scope one example's launch token set cannot leak into the next example's session-only request, whatever the test framework's own reset of `Current` does.
- **Refusals the plan built by hand are logged too** (step 5). The plan's `Catalog` raised its 404 and malformed-answer refusals, and `RunPackage` its malformed-202 refusal, without going through `Upstream.refusal`, so none wrote R30's warning. The malformed answers now go through `Upstream.malformed(upstream, status, reason, message)`, which logs and builds the 502 as `Upstream.refusal` does. The resolve 404 goes through `Upstream.refusal` with status 409, so its message ends with report-server's own reason after the plan's wording (`... cannot be resolved: it does not exist or you may not see it: <reason>`).
- **A resolve 200 whose JSON does not parse is a 502** (step 5). The plan's `Catalog` read `response.parsed_response` unguarded, and HTTParty parses lazily, so a truncated `application/json` body raised `JSON::ParserError` as a Rails 500. `Upstream.parsed` returns nil for it, and both `Catalog` and `RunPackage` read bodies through it.
- **A 202 must carry the queue state** (step 5). The plan accepted any JSON object; the code requires `queue` and `appended` to be lists and `vm` a string, and answers anything else with the malformed-202 502. It does not check the queue entries' keys, which REPORT-141 owns (Decisions).
- **A FirebaseApp setting that names no row is a 503** (step 5). `SignedJwt.create_firebase_token` raises `SignedJwt::Error` for an unknown name, which the controller does not rescue, so a portal with `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` set before its FirebaseApp row existed answered a bare 500. `Settings.firebase_app` and `clue_firebase_app` now raise `NotConfigured` naming the variable and the missing row, before anything is minted or sent.
- **The run path's specs split by layer** (step 5). `run_package_spec.rb` covers the service: the posted body, the tokens and assertions, the CLUE token, all-or-nothing resolution, each function answer and the configuration refusals. The controller spec's `run_package` block covers what only the action can show: the 202 body sliced to the queue state, the 400s for a caller-supplied checksum, a scope key, malformed JSON and a non-object body, the error envelope around the function's 409, the 503, two researchers' independent answers, and the 401, 403 and 404 gates.
- **Verification** (2026-09-24, after step 6). The dashboard's own specs: 154 examples, 0 failures. The full rspec suite (`docker/dev/run-spec.sh`): 3,207 examples, 3 failures, 203 pending. The three failures are in `research_classes_controller_spec.rb` and come from this machine's `.env`, which sets `RESEARCHER_DASHBOARD_URL`. The test container inherits it, so each class row gains the `researcher_dashboard_url` RIGSE-367 adds; the file passes (21 examples) with the variable blanked, and CI sets no such variable. The `react-components` jest suite: 173 tests, 2 failures, both in `external-report-button.test.tsx`, which fail identically on master under a full run on this machine (Node 24; CI uses 18) and pass when that file runs alone. This branch changes nothing in `react-components`. The stack template lints clean with `cfn-lint`, and `docker compose config` shows the four variables.
- **The requirements were compared with the code, requirement by requirement, after step 6.** Nothing was missing. One reading was recorded as a judgment call, the bare 404 while the dashboard is disabled, which the rework then deleted along with the disabled state itself.

#### The rework onto RIGSE-367's redesigned token model

The branch was rebased onto `RIGSE-367-oauth-pkce-scoped-tokens` and the code reworked on 2026-09-29. Beside what the redesign section above names:

- **The class the controller acts on is the token's context, loaded once.** `authorize_scope` reads `Current.token_context`, refuses a token bound to nothing or to a type other than `class` with 403, answers 404 for a class that has been deleted, then runs `require_token_capability!` for the action's capability and `can_be_researcher_for_clazz?`. `ACTION_CAPABILITIES` is the one place each action's capability is written: the `accepts_token_capability` declarations are generated from it, so the declaration and the check cannot name different capabilities.
- **A capability refusal on these endpoints uses the API error envelope.** `TokenCapabilityCheck#token_capability_denied` renders `{success, message}`; the controller overrides it with `error(...)`, so R28's shape covers every refusal these three actions make.
- **`Settings.require_signing_key!` joins the other configuration checks.** Both the refresh and the run path sign an assertion, and a token signed by a previous key still verifies while `PORTAL_SIGNING_KEY` is unset or malformed, which would otherwise raise `SignedJwt::Error` as a 500. Each service calls it before anything is resolved or sent.
- **Nothing reads `params`, so nothing parses the body.** `check_for_auth_token(params, ...)` was what forced Rails to parse it, so the controller's `ActionDispatch::Http::Parameters::ParseError` handler went with it and the message it rendered has one definition again. `RunRequest.parse` answers every malformed run body from `request.raw_post`, and `refresh_profile`, which takes no body (R11), ignores one rather than refusing it.
- **The resolve bearer is the request's own access token**, read from the `Authorization` header with `PortalBearer.raw_token`; `Catalog.resolve` and `RunPackage.call` take it as `access_token:`.
- **A request spec covers what a controller spec cannot.** `rails/spec/requests/researcher_dashboard_api_spec.rb` presents a real bearer through the routes and the Devise strategy: the class in the token and only it, no session stored for a scoped token, a signed-in session refused, and a read-only token refused on the run path. The controller spec's two-request example resets Warden between calls, since a controller spec reuses one request environment and Warden memoizes both the user and the strategies that ran.
- **Verification of the rework** (2026-09-29). The dashboard's own specs, `scoped_oauth_flow_spec.rb`, `token_scope_spec.rb`, `token_capabilities_spec.rb`, `token_capability_check_spec.rb` and `jwt_controller_scoped_spec.rb`: 183 examples, 0 failures. The full rspec suite (`docker/dev/run-spec.sh`): 3,250 examples, 0 failures, 202 pending. The three `research_classes_controller_spec.rb` failures of the 2026-09-24 run are gone with `RESEARCHER_DASHBOARD_URL`, which no longer exists for this machine's `.env` to set. Nothing in `react-components` changed.

## Out of Scope

- Anything in report-service: the function's validation, queue and VM handling (REPORT-141), the catalog, resolve and deriver (REPORT-142), `/work` and the dashboard's Firestore rules (REPORT-143).
- The app's use of these endpoints, the profile's maximum age and when the app asks for a refresh: RD-3.
- Deleting the CLUE class-token mint and its setting: RIGSE-369.
- Moving feedback metadata off `REPORT_SERVICE_BEARER_TOKEN` (RIGSE-367 R23).
- A second scope kind. The endpoints refuse a token whose `context` is not a class; a cohort scope is `final-design.md` section 15.1's extension, and the routes are shaped so that it costs a `TokenCapabilities` registry entry and a context expansion rather than new endpoints (Decisions).
- Deleting spike-only code (see the set-aside clauses in Background).

## Not Yet Implemented

- Enabling the refresh and the run path on the staging and production stacks — the release process updates stacks with their previous template, so the three parameters this branch adds (`ResearcherDashboardFunctionURL`, `ResearcherDashboardFirebaseApp`, `ResearcherDashboardClueFirebaseApp`), beside RIGSE-367's `ReportServerURL`, reach a stack only through a deliberate template update per environment; until then the scope endpoint works and the refresh and run path answer 503 naming the missing setting.

## Decisions

### The endpoints name no class in their routes

**Context**: The redesign's token carries its scope in a `context` claim, so the class in `GET .../classes/:id` and `POST .../classes/:id/refresh_profile` duplicated something the credential already said, and `run_package` never had a path id at all. Decided during the rework (2026-09-29).
**Options considered**:
- A) `GET /scope`, `POST /refresh_profile` and `POST /run_package`, all three taking the class from `Current.token_context`, with `kind` added to the metadata body beside the class fields.
- B) Keep `classes/:id` on the two that had it and compare the path id with the token's context, as R4 did.

**Decision**: A. There is then no path id to disagree with the scope, so `require_path_matches_scope` and R4's integer comparison go away and the two ways of naming a class cannot drift apart; what is left is the capability check against the token's own context and the researcher gate. It also decides what a second scope kind costs: a cohort scope is a `TokenCapabilities` registry entry and a method expanding a context into its classes, answered by the same three routes, where B would have needed `cohorts/:id` beside `classes/:id` on every endpoint. `kind` in the metadata body is the same discriminator `scope.json` carries with `id` and `classes`, so the app reads the scope's shape from the one field in both places. The cost is that a person cannot read a request's class out of its URL, which the token's `context` claim carries instead.

---

### rigse cannot learn `clue_prepull` from the resolve answer

**Context**: R19 and R20 mint the CLUE class token when a package declares `clue_prepull`, and R17 says rigse learns about a package only from `GET /api/v1/packages/resolve`. REPORT-142's resolve answers `{catalog_id, identity, version, checksum, expected_duration_seconds, archived, runnable, reason}` (its implementation spec, the reading step): no `clue_prepull`, although it is a column of the `package_versions` row the resolve already joins. The list endpoint carries it, but only for each package's current version, and rigse must also run a non-current version.
**Options considered**:
- A) Amend REPORT-142's resolve to also answer `clue_prepull` from the version row. One field, no new query; rigse is the resolve's only consumer.
- B) rigse always mints the CLUE class token on every run. No cross-story change, but every run's `work/` document then holds a token able to read the class's CLUE documents, including runs of packages that never asked for them.
- C) rigse also calls `GET /api/v1/packages` and reads `clue_prepull` from each package's current version, refusing or guessing for a non-current version.

**Decision**: A (Doug, 2026-09-24). REPORT-142's R17 and its reading step were amended on its branch the same day: the resolve now answers `clue_prepull` from the resolved version's row. Recorded in R17 and R19.

---

### The fingerprint's shape

**Context**: The story leaves the shape to this story, requiring only that it change when the assignment set changes. The profile document is a function of the URL list alone, so a fingerprint of the URLs would skip refreshes that produce an identical document, while a fingerprint of the offerings changes on exactly what the story names.
**Options considered**:
- A) A versioned hash of the sorted `(offering_id, url)` pairs: changes when an offering is added or removed or its URL changes.
- B) A versioned hash of the sorted distinct URLs: changes only when the profile's input changes.
- C) The latest `updated_at` among the offerings.

**Decision**: A, as `v1:` followed by the lowercase hex SHA-256 of the JSON array of `[offering_id, url]` pairs sorted by offering id, 67 characters. It meets the story's one requirement literally: B does not change when a second offering of an already-assigned activity is added or removed, which the story counts as the assignment set changing. The cost of A over B is a refresh that rewrites an identical profile in that case, which is one Cloud Task and is harmless because the deriver is idempotent (REPORT-142 R25). C misses a removal (a deleted offering leaves no `updated_at` behind) and changes on edits that do not touch the assignment set, such as reordering. Hashing JSON rather than a joined string keeps a URL containing the separator from colliding with two URLs; the `v1:` prefix lets a later shape change force one refresh everywhere instead of comparing unlike values. It is computed from the offerings R8 lists, including inactive ones and ones whose URL R11 leaves out of the refresh body, so the metadata endpoint and `refresh_profile` always agree. Recorded in R10.

---

### Which Firebase projects get a class token, and where rigse learns their names

**Context**: The spike took `firebase_project` and `firebase_apps` from the app. The story's body is packages only, and section 13 says which project holds CLUE is "runner and rigse configuration per environment". The runner requires `class_tokens[firebase_project]`.
**Options considered**:
- A) Two settings: the report-service FirebaseApp (always minted, also `firebase_project`) and the CLUE FirebaseApp (minted when `clue_prepull`).
- B) Derive the set from the FirebaseApp rows present.
- C) Keep taking the names from the app.

**Decision**: A. C contradicts the story's "takes `{packages}` and nothing else". B would mint a runner token in every Firebase project the portal happens to hold a key for (production portals hold keys for projects unrelated to the dashboard), which is exactly the unasked-for credential spread the runner claim exists to contain. The runner reads its own class token as `class_tokens[firebase_project]` and refuses a run without one (`researcher-dashboard/runner/server/runner.js:336-339`), so the report-service token is always minted; the CLUE token only when R20 says. The CLUE setting is the one RIGSE-369 deletes. Recorded in R19 and R29.

---

### REPORT-141's `/run-package` validation expects a bare hex checksum

**Context**: REPORT-141's implementation spec validates `checksum` as "a hex string" (its queueing step), while REPORT-142 R9 and the resolve answer give `sha256:<lowercase hex>`, which is also what the runner computes and compares (`researcher-dashboard/runner/server/package-fetch.js:20`). rigse forwards the catalog's checksum verbatim (R17), so if REPORT-141 is built as written every run is refused 400.
**Options considered**:
- A) rigse sends the catalog's value unchanged, and REPORT-141's validation is corrected to `^sha256:[0-9a-f]{64}$`.
- B) rigse strips the `sha256:` prefix before sending, and the runner's comparison changes to match.

**Decision**: A for rigse's side, which needs no decision: the catalog, the runner and the design all use `sha256:<hex>`, and B would make rigse the one component rewriting a value it is supposed to carry untouched. REPORT-141's spec was the one in error. At stage 8, Doug approved correcting it (2026-09-24), and its R13 and queueing step now validate `^sha256:[0-9a-f]{64}$` and accept an assignment with `url: ""` and `name: null`, which R8 can send. Recorded in R17 and R22.

---

### The endpoints accept only a scoped credential

**Context**: A session cookie, an HS256 portal token and an AccessGrant all authenticate a full user and carry no scope, and `TokenScope.allows?` passes every one of them, so the capability checks alone would let a session through.
**Options considered**:
- A) Refuse every credential that carries no scope (R1).
- B) Accept any credential and take the class from the path for unscoped callers.

**Decision**: A. The story gates each endpoint on "the scope in the verified bearer", and with no class in the route (Decisions) an unscoped caller names no class at all. Accepting a session would also make the two POSTs reachable by a cross-site form, since the controller skips the CSRF check, and would give a portal session a path to mint runner tokens. The app is the only caller. Recorded as R1.

---

### Refuse unknown keys in the run body rather than ignore them

**Options considered**:
- A) 400 for any key but `packages`, and any entry key but `identity` and `version`.
- B) Read `identity` and `version` and ignore the rest.

**Decision**: A. The story says the body is those two fields "and nothing else" and that rigse must not accept a checksum or package key from the caller. Ignoring them would meet the letter, but refusing them makes a stale client that still sends a checksum fail loudly instead of appearing to choose its package bytes. Recorded as R16.

---

### Refuse an oversized assignment list rather than truncate it

**Options considered**:
- A) 422 without calling the function when the URL list exceeds REPORT-142's count or body limit.
- B) Send the first 500 sorted URLs.

**Decision**: A. A truncated list derives a profile that silently omits assignments, so packages matching them are silently not offered, which is the failure `final-design.md` 5.5 warns against. A class with more than 500 distinct assignment URLs, or 256 KiB of them, is far outside anything measured (35 activities gave 54 interactive URLs), and a visible refusal is the better failure for a case that should not happen. A single URL over 2,048 characters is left out instead, because refusing the whole class for one malformed row would deny every package to it. Recorded as R11 and R14.

---

### R16's "exactly this body" cannot be checked against `params`

`config.load_defaults 7.0` turns on JSON parameter wrapping, so a scratch controller spec posting `{"packages": [...]}` saw `params.keys` of `packages, format, controller, action, researcher_dashboard` and `request.request_parameters.keys` of `packages, researcher_dashboard`. A top-level key check over either would refuse every valid request, and an unparsable body raised `ActionDispatch::Http::Parameters::ParseError` before the action. Fixed: R16 checks the parsed request body and names a non-object body as a 400.

---

### One `Refusal` type rendered by `rescue_from`, rather than status handling in the controller

**Options considered**:
- A) Services raise `ResearcherDashboard::Refusal(status, message, details)` and the controller renders it once.
- B) Services return result objects and the controller maps each outcome to a status, as the spike's controller did with three rescue clauses.

**Decision**: A. The run path has a dozen distinct refusals across three services, and R28 requires every one to have the same body shape; one `rescue_from` makes that true by construction and keeps the actions to two lines each. The spike's mapping (`e.status.to_i == 409 ? 409 : 502`) is the pattern R23 keeps, now inside `Upstream.refusal`.

---

### Read timeouts of 10 seconds for the resolve and the refresh, 45 for `/run-package`

**Options considered**:
- A) 10, 10 and 45 seconds, with a 5-second open timeout everywhere.
- B) HTTParty's default (none set, so Net::HTTP's 60 seconds).

**Decision**: A. The resolve's slowest honest answer is report-server's five-second portal timeout (REPORT-142 R15) plus its own work, and the refresh only enqueues a Cloud Task, so for those two a hung upstream is reported in seconds rather than holding a Puma thread for a minute. `/run-package` records the queue and then makes at most `GetMicrovm` and either `ResumeMicrovm`, or `GetMicrovmImage`, report-server's mint and `RunMicrovm`, plus its Firestore transactions. None of these waits for a VM. As implemented, REPORT-141 makes each upstream call once with a 10-second timeout and answers 502 with the reason. 45 seconds covers the four 10-second timeouts with 5 seconds left for its Firestore transactions and a cold start, so rigse hears the function's own reason where 25 would have turned a slow upstream into rigse's 504. Only the function's own 60-second timeout bounds it fully, and `/run-package` can hold a Puma thread for up to 50 seconds, the price of hearing that reason (amended 2026-09-24). A `/run-package` timeout says the work may be queued, which is true because REPORT-141 writes the queue first (R27).

---

### Resolve sequentially and stop at the first refusal

**Options considered**:
- A) One resolve at a time, stopping at the first refusal.
- B) All resolves in parallel threads.

**Decision**: A. A batch is at most 20 and typically one to three; each resolve makes report-server read the portal (REPORT-142 R15), so parallel resolves multiply portal load for a saving of a second at most. Stopping early also means a refused batch reports the first bad package and costs nothing more.

---

### Skip the CSRF check on the dashboard controller

**Context**: The plan's controller left `protect_from_forgery`'s null-session strategy in place. Decided during step 3.
**Options considered**:
- A) `skip_before_action :verify_authenticity_token`, as `jwt_controller`, `oidc_mint_controller` and the other bearer-only `/api/v1` controllers do.
- B) Keep the null session, which lets a bearer POST through but logs a CSRF warning for each one.

**Decision**: A. The endpoints read no session and refuse every request without a scoped bearer (R1), so there is nothing for a forged request to ride, and B's only effect is a warning on every run and refresh. Recorded in "As built" under Technical Notes.

---

### How strictly to read the function's 202

**Context**: The plan accepted any JSON object as the 202 and sliced `queue`, `appended` and `vm` from it. The step 5 review found that a 202 of `{}` would then be answered 202 `{}`. Decided during step 5, against REPORT-141 as built (`functions/src/researcher-dashboard/run-package.ts`), whose 202 is `{success: true, queue: [{class_hash, package_key}], appended: [package_key], vm}`.
**Options considered**:
- A) Require `queue` and `appended` to be lists and `vm` a string, and answer anything else 502.
- B) Keep the plan's check, a JSON object.
- C) Validate each queue entry's keys as well.

**Decision**: A. The app renders the queue from this answer, so a success without it is a failure the app cannot show, and a 502 names it. C would couple rigse to the shape of the function's queue entries, which rigse only relays and REPORT-141 owns. Recorded in "As built" under Technical Notes.

---

### Where a missing FirebaseApp row becomes a 503

**Context**: The step 5 review found that a FirebaseApp setting naming no row raised `SignedJwt::Error` from the mint, which the controller does not rescue, so the run path answered a bare 500.
**Options considered**:
- A) `Settings.firebase_app` and `clue_firebase_app` check the row exists and raise `NotConfigured`.
- B) `RunPackage` rescues `SignedJwt::Error` around the mint and re-raises it as `NotConfigured`.

**Decision**: A. The check then happens where the setting is read, after the resolves and before anything is minted, and it names the variable. B would also turn any other signing failure (a malformed private key, say) into a message blaming the setting. The extra query runs only on the run path. Recorded in "As built" under Technical Notes.

---

### A dropped connection or a garbled response would still surface as a Rails 500

`Upstream` rescued `Timeout::Error`, `SocketError`, `SystemCallError`, SSL errors and `HTTParty::Error`. On the portal image's Ruby, `EOFError` (a connection closed mid-response) descends from `IOError`, and `Net::HTTPBadResponse` and `Net::ProtocolError` from `StandardError` directly, so none was caught, against R27. Fixed: `Upstream::CONNECTION_ERRORS` adds `IOError`, `Net::HTTPBadResponse` and `Net::ProtocolError`. Checked: a resolve stubbed to raise `EOFError` now answers 502 `report-server could not be reached`.

---

### A 202 whose body is not a JSON object raised `ArgumentError`

`response.parsed_response.slice('queue', 'appended', 'vm')` is `String#slice` when the body is text, and `String#slice` with three string arguments raises `ArgumentError` (checked on the portal image), which would be a 500 after the work was queued. Fixed: `RunPackage` answers 502 naming the malformed answer unless the body is a Hash. Checked: a stubbed `text/plain` 202 answers 502.

---

### Nothing recorded an upstream refusal server-side

The plan reported each refusal's reason to the browser (R28) and wrote nothing to the portal's log, so a researcher's "my run failed" had no server-side trace beyond a 502 status line. Fixed: `Upstream` writes one `researcher_dashboard.upstream_refusal upstream=... status=... reason=...` warning for every refusal, timeout and connection failure, with no request body and so no token. Stage 8 found no requirement for it; Doug added it as R30 (2026-09-24).
