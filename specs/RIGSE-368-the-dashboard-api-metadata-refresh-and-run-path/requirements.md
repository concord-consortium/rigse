# The dashboard API: scope metadata, the profile refresh and the run path

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-368
**Repo**: https://github.com/concord-consortium/rigse
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

rigse gains the three endpoints the Researcher Dashboard app calls with its launch token: one describing the class it was launched into, one asking report-service to rebuild the class's authored URL profile, and one queueing a batch of packages to run. All three check that the researcher may open the class on every call, and the run path answers as soon as report-service has accepted the work instead of waiting for a VM.

## Project Owner Overview

When a researcher opens the Researcher Dashboard on a class, the page needs to know what the class is, who teaches it, what was assigned in it, and whether its cached list of assigned activities and interactives is out of date. This story gives the page one portal call that answers all of that, and a second one that asks for the list to be rebuilt when the class's assignments have changed. The portal supplies the list of assignment links itself, so nothing outside the portal can make report-service fetch an arbitrary web address.

It also gives the page the call that starts analyses. The researcher picks one or more packages, the portal checks each one against the catalog (so a package that is archived, or that the researcher may not run, is refused with a reason on the spot), creates the short-lived credentials the run needs, and hands the work to report-service. The page gets its answer in about a second instead of waiting up to three minutes for an analysis machine to start, which is what the prototype did and why its failures all looked the same.

## Background

RIGSE-368 is derived from `final-design.md` sections 4, 5.5, 6.1, 10, 11.2 and 13 and the renames in section 3. The Jira description is the authoritative scope and is not restated in full here; this spec records how it lands on the RIGSE-367 branch, which it stacks on, and the contracts it takes from the three specs at the other end of its calls.

**What it builds on (RIGSE-367, closed spec `specs/RIGSE-367-the-portal-signing-key-and-the-scoped-launch-token.md`).** RIGSE-367 is implemented on its branch (PR #1487), which this branch is stacked on, so every name below is in the code this story starts from. Two behaviors settled in its implementation and review also hold here: `check_for_auth_token` refuses an `aud: researcher-dashboard` token missing `scope_kind` or `scope_id`, and `jwt/firebase` accepts the launch token only on GET.
- `SignedJwt.decode_portal_token(token, aud:)` verifies RS256 tokens by `kid` with the audience named by the call site, and `API::APIController#check_for_auth_token(params, aud:)` sets `Current.token_scope_kind` and `Current.token_scope_id` when the bearer is an RS256 token (RIGSE-367 implementation, step 1). A launch token carries `scope_kind: "class"` and `scope_id` as the class's integer id (R15 there).
- The launch token is accepted only on `jwt/firebase?researcher=true` and on the `/api/v1/researcher_dashboard/*` endpoints this story adds (RIGSE-367 R11a).
- `User#can_be_researcher_for_clazz?` is the one researcher gate (R13 there).
- `ResearcherDashboard.enabled?` is true when both `RESEARCHER_DASHBOARD_URL` and the signing key are configured (R14 there).
- `ResearcherDashboard::Assertions.report_server(user:, clazz:)` and `.report_service_functions(user:)` mint the two service assertions, each living 120 seconds; the `report-server` one carries a fresh `jti` per call (RIGSE-367 implementation, the service assertions step).

**The other ends of its calls.**
- **report-service REPORT-141** (branch `REPORT-141-portal-key-verification`). `POST /run-package` is on the separate `researcherDashboard` HTTPS function, whose URL is also the runner's `function_url`. It accepts only an `aud: report-service-functions` bearer and takes the researcher and portal from that assertion's `uid` and `iss`, never the body. Its body is `packages: [{identity, version, checksum, catalog_id}]`, `scope: {kind, collection, id, classes: [{class_hash, class_id}], assignments: [{offering_id, runnable_id, name, url}]}`, `class_tokens` (FirebaseApp name to token), `session_token`, `firebase_project` and `report_server_assertion`, which it verifies (same `uid` and `iss` as the request's assertion) and relays to report-server only on the branch that launches a VM. It validates the whole batch before writing, queues by class (`scopes.{class_hash}`), and answers:
  - 202 `{queue, appended, vm}`, where `vm` is `launched`, `launching`, `resumed`, `running` or `suspending`
  - 400 naming the field for a malformed body; `scope.classes[0].class_hash` must be 48 lowercase hex
  - 401 for a bad bearer
  - 409 `queue at its cap (N outstanding)`
  - 502 carrying the upstream status and reason when report-server's mint or the MicroVM API fails after the work was queued
  - 500 for its own misconfiguration (a malformed `PORTAL_PUBLIC_KEYS`, a launch payload over the platform's cap) or an unexpected failure
  - 503 naming the unset settings, with nothing written, while any of its launch settings (the runner stack's image, role and bucket, and the report-server URL) is empty; production answers this until its runner stack exists, since its image, role and bucket are empty

  Every error body is `{"success": false, "error": "<reason>"}`. It never waits for a VM, and each of its upstream calls is made once with a 10-second timeout (REPORT-141 as implemented, 2026-09-24).
- **report-service REPORT-142** (branch `REPORT-142-catalog-and-url-profile`).
  - `GET /api/v1/packages/resolve?identity=&version=` on report-server, presented with the app's launch token (report-server verifies the `researcher-dashboard` audience with REPORT-141's verifier). It answers `{catalog_id, identity, version, checksum, expected_duration_seconds, clue_prepull, archived, runnable, reason}` (`clue_prepull` added to REPORT-142 for this story, see Open Questions), with checksums as `sha256:<hex>`; a package the caller may not see is 404, the same as a missing one; an archived package, or any non-official one until report-server's unreviewed-runs switch is on, answers 200 with `runnable: false` and a `reason`. Errors are the flat `{"error": CODE, "message": ...}`; a portal read timing out is 503, and an unknown portal, or a `uid` the portal does not know, is 401. A request with no `Origin` header is not origin-checked, and a resolve without the launch token is 401 (REPORT-142 as implemented, 2026-09-24).
  - `POST /derive-profile` on the `researcherDashboard` function, behind the same `report-service-functions` auth. Body `{class_hash, assignment_fingerprint, assignment_urls}`: `class_hash` is 48 lowercase hex, the fingerprint a non-empty string of at most 256 characters, at most 500 URLs of at most 2,048 characters each, and the whole body at most 256 KiB; anything else is 400 and nothing is queued. A valid request is 202 `{success: true, queued: true}` once a Cloud Task is queued; an enqueue failure is 502, and while the function's `RD_AUTHORING_HOSTS` allowlist is empty every request is 503 `{success: false, error}` naming it, with nothing queued (REPORT-142 as implemented, 2026-09-24). R15 passes either through as a 502. The derivation writes `researcher_dashboard/{portal}/classes/{class_hash}` whole, including `assignment_fingerprint` and `assignment_urls` exactly as given, and never overwrites a newer request's document.

**What master has today.** None of the dashboard API. Checked on master and on the RIGSE-367 branch:
- There is no `API::V1::ResearcherDashboardController`, no `researcher_dashboard` route under `/api/v1`, and no CORS entry for it. `final-design.md` section 4 says "the launch action and the metadata endpoint exist today for `class`"; both exist only on the spike branch (`RIGSE-365-runner-token-service`), so the metadata endpoint is built fresh here rather than changed.
- **Offerings.** `Portal::Clazz#offerings` is ordered by `position`. `ExternalActivity` is the only model declaring `has_many :offerings, as: :runnable` (`external_activity.rb:88`), but the polymorphic column is not constrained: an offering whose `runnable_type` names a model that no longer exists raises `NameError` when its runnable is loaded (probe, see Verification), which is why `research_classes_controller.rb:19` and `report_users_controller.rb:82` filter on `runnable_type = 'ExternalActivity'` explicitly.
- **`external_activities.url`** is a `mediumtext` column. `ExternalActivity#url` is not the stored value: without a learner it returns `URI.parse(stored).to_s`, which lowercases the scheme and drops a default port, and falls back to the stored string when parsing fails (`external_activity.rb:142-164`; probe, see Verification). The stored value is `read_attribute(:url)`. The model's `valid_url` check accepts an empty string, so a stored URL can be `""`. Activity Player assignments carry the activity or sequence JSON as `activity=` or `sequence=` (`lib/tasks/lara2.rake`), which is what REPORT-142's deriver follows; a legacy LARA URL is taken as it stands.
- **`tools`** holds `name`, `source_type`, `tool_id`, `remote_duplicate_url` and `launch_method`; an external activity may have no tool. The default setup names the Activity Player tool `ActivityPlayer` for both `name` and `source_type` (`lib/tasks/app.rake`, `create_default_tools`), and `source_type` is what `DefaultReportService` and `lara_activity_or_sequence?` branch on. The spike's controller reported `source_type` as `platform`; this story reports `name` as `tool` (section 3).
- **Teachers, cohorts and projects.** A class has teachers through `portal_teacher_clazzes`; a teacher has cohorts through `admin_cohort_items` (`lib/cohorts.rb`) and projects through its cohorts (`portal/teacher.rb:36`). "The projects the class belongs to" is the same relation the researcher gate joins through (`User#with_teacher_clazzes`, shared by `is_researcher_for_clazz?`, `is_project_admin_for_clazz?` and `researcher_clazz_ids`): the projects of the cohorts of the class's teachers.
- **`class_hash`** is `SecureRandom.hex(24)`, 48 lowercase hex characters, generated before save and backfilled for existing classes by `20170202190333_add_class_hash.rb`, so it matches REPORT-142's `class_hash` rule.
- **Firebase custom tokens.** `SignedJwt.create_firebase_token(uid, firebase_app_name, expires_in, claims)` signs with the named `FirebaseApp` row's service-account key and raises `SignedJwt::Error` for an unknown name. `jwt_controller#firebase` builds the researcher claims inline: `claims: {platform_id, platform_user_id, user_id, user_type, class_hash}` with `uid = MD5(user_id)`. The runner names projects by FirebaseApp name, and reads its own class token as `class_tokens[firebase_project]` (`researcher-dashboard/runner/server/runner.js:336`), so the FirebaseApp names rigse keys by are the Firebase project ids.
- **Outbound HTTP** in rigse uses `HTTParty` (`students_controller.rb#get_feedback_metadata`), and specs stub it with WebMock (`spec/spec_helper_common.rb`, `disable_net_connect!`).
- **Errors** from `API::APIController#error` are `{success: false, response_type: "ERROR", message, details?}`. The spike app reads `message` (or `error`) from any non-2xx body and treats 401 and 403 alike as an expired launch (`researcher-dashboard/app/src/shell/portal.ts:38`).
- **Configuration.** rigse has `REPORT_SERVICE_URL`, which is the function app's `api` function and is used only by feedback metadata, and `REPORT_SERVER_REPORTS_URL`, a link to report-server's reports UI. It has no report-server API base URL and no URL for the `researcherDashboard` function.

**What the spike built, and what changes.** The spike's controller (`app/controllers/api/v1/researcher_dashboard_controller.rb` on the spike) and `ResearcherDashboard::RunPackage` took `class_id`, a caller-supplied `{name, version, checksum}`, `firebase_project` and `firebase_apps` in the body, posted to `REPORT_SERVICE_URL/run_package` with `REPORT_SERVICE_BEARER_TOKEN` and a 30-second timeout while report-service waited up to 180 seconds for the VM, and did not rescue `Net::ReadTimeout`. Its metadata endpoint returned `teacher_names`, `cohort_names` and assignments as `{id, runnable_id, name, platform}` with no URL. Its `RunnerToken` minted the session and class tokens with `researcher_dashboard_runner: true`, which this story keeps in shape. Everything else is replaced: the scope comes from the bearer, the checksum from the catalog, the Firebase projects from configuration, the credential is the assertion, and nothing waits.

**Clauses of the Jira story set aside, and why.** Per the sprint's branching rule, a clause that deletes or renames something that exists only on the spike is ignored. Each was checked against master and the RIGSE-367 branch:

| Jira clause | On master? | Treatment |
|---|---|---|
| "The `platform` field is renamed `tool`" | No: the metadata endpoint and its `platform` field are spike only | Set aside as a rename. The endpoint is built with `tool` from the start and never has `platform` (R7). The Done-when "`platform` is gone from the response" holds by construction and is still asserted (R7). |
| "The wait is deleted: no `waitUntilRunning`, no 30-second-against-180-second timeout, no unrescued `Net::ReadTimeout`" | No: `run_package` is spike only | Set aside as a deletion. Restated as requirements on the new path, which never waits and rescues its own timeouts (R26, R27). |

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

- **Files this story touches**, on top of RIGSE-367's: new `rails/app/controllers/api/v1/researcher_dashboard_controller.rb`; new services under `rails/app/services/researcher_dashboard/` for the scope's assignments and fingerprint, the catalog resolve, the runner-token mint and the two function calls; `rails/config/routes.rb`; `rails/config/application.rb` (CORS); `docker-compose.yml`, `configs/cloudformation/stack_template.yml`, `README.md`; specs under `rails/spec/controllers/api/v1/` and `rails/spec/services/researcher_dashboard/`.
- **Route shape.** The spike routed `get 'classes/:id', to: '/api/v1/researcher_dashboard#clazz'` inside `namespace :researcher_dashboard`, with an absolute controller path because `to:` inside a namespace resolves one level deeper.
- **Runner claim.** `researcher_dashboard_runner: true` is the claim report-service's rules and CLUE-692's deny-write rules key on (`final-design.md` 9 and 13); the spike's `RunnerToken` is the reference shape.
- **Firebase custom tokens live at most one hour** (`exp - iat <= 3600`), and the class tokens sit in `work/{uid}` until the VM takes the work. A package queued behind more than an hour of other work reaches the VM with an expired custom token; whether the runner signs in once per class early enough is RD-4's and REPORT-143's concern (REPORT-143's `/work` also hands out "a fresh session token"). rigse mints at request time and can do no better.
- **report-server resolves the caller's grants from the portal on every resolve** (REPORT-142 R15, a five-second portal timeout), so a twenty-package batch is twenty portal round trips from report-server; sequential resolves keep the portal load one request deep.
- **The `work/` document holds the scope block**, including the assignments, and Firestore caps a document at 1 MiB. A class with several hundred assignments of long URLs approaches that; REPORT-141 owns the document.
- **Where the other halves are specified**: the function's validation, queue and VM branch (REPORT-141), the resolve and the deriver (REPORT-142), `/work` and the rules (REPORT-143), the runner (RD-4), the app's use of all three endpoints (RD-3), and the eventual deletion of the CLUE mint (RIGSE-369).

## Verification

Stage 1 ran throwaway probes, deleted afterwards and never committed:

- **`ExternalActivity#url` against the stored value** (the portal image's Ruby, and again through the model in a scratch spec in the test database). `HTTPS://Activity-Player.concord.org/?activity=...` came back with the scheme lowercased; `https://example.com:443/x` lost its port; a URL with a space or a `|` failed to parse and came back raw; an encoded Activity Player URL and a protocol-relative URL round-tripped. So "the URL exactly as `external_activities` stores it" is `read_attribute(:url)`.
- **A legacy `runnable_type`.** An offering whose `runnable_type` was set to `Investigation` made `clazz.offerings.map(&:runnable)` raise `NameError: uninitialized constant Investigation`, while `offerings.where(runnable_type: 'ExternalActivity')` loaded the rest. Hence R9.
- **Blank URLs and names.** `ExternalActivity.new(name: 'x', url: '')` is valid, and the factory's external activity has a nil name, so `url` can be `""` and `name` null.
- **Cohorts and projects.** A teacher created with a cohort of a project reports that cohort and that project; `class_hash` is 48 lowercase hex.

**Stage 4, the spec's load-bearing assumptions run as throwaway code.** RIGSE-367's token primitives (its implementation step 1: `PortalSigningKey`, the audience-aware `create_portal_token` and `decode_portal_token`, `Current.token_scope_*` in `check_for_auth_token`, and `can_be_researcher_for_clazz?`) were applied to the working tree from its spec, with a minimal controller implementing R1 to R4 and the CORS entry of R6, then reverted.

| Case | Result |
|---|---|
| Launch token for class A, `GET classes/A` | 200; `current_user` nil inside the action, the user from `check_for_auth_token`, `scope_id` an `Integer` |
| Same token, `classes/<A>abc` and `classes/B` | 403 (R4) |
| Token with `scope_kind: "cohort"` | 403 (R2) |
| `aud: report-server` token | 401, refused by the decoder's audience check |
| Legacy HS256 portal token, and a Devise session with no bearer | 401: both authenticate, but neither sets a scope, which is what R1 refuses on |
| Launch token for a user who fails the gate | 403 (R3) |
| Expired launch token | 401 (`JWT::ExpiredSignature`) |
| R10's fingerprint over no offerings, one, a second of the same activity, the activity's URL changed, the second offering removed | five distinct values, 67 characters, stable on recomputation |
| Firebase custom token with the runner claims for FirebaseApp `collaborative-learning-staging` | decodes with `researcher_dashboard_runner: true` and `class_hash` under `claims`, `exp - iat = 3600`; an unknown FirebaseApp name raises `SignedJwt::Error` |
| HTTParty 0.22 under WebMock: a connect timeout, a read timeout | `Net::OpenTimeout` and `Net::ReadTimeout`, both `Timeout::Error` |
| HTTParty on a JSON 409 body and a `text/plain` 502 body | a parsed hash and the raw string, so R28's reason reader handles both |
| `URI.encode_www_form(identity: "projects/20/class-counts", ...)` | `identity=projects%2F20%2Fclass-counts`, so the identity's slashes survive the resolve query |
| CORS preflight for `POST /api/v1/researcher_dashboard/run_package` with `authorization,content-type` | 200, `Access-Control-Allow-Origin: *`, methods `GET, POST`, the requested headers allowed |

One side effect worth knowing: every launch-token request also logs `JwtBearerToken: decode error - This endpoint does not accept RS256 portal tokens` from the Devise strategy, which runs first and refuses the token as RIGSE-367 intends.

## Out of Scope

- Anything in report-service: the function's validation, queue and VM handling (REPORT-141), the catalog, resolve and deriver (REPORT-142), `/work` and the dashboard's Firestore rules (REPORT-143).
- The app's use of these endpoints, the profile's maximum age and when the app asks for a refresh: RD-3.
- Deleting the CLUE class-token mint and its setting: RIGSE-369.
- Moving feedback metadata off `REPORT_SERVICE_BEARER_TOKEN` (RIGSE-367 R23).
- A second scope kind. The endpoints refuse any `scope_kind` but `class` (R2); a cohort scope is `final-design.md` section 15.1's extension.
- Deleting spike-only code (see the set-aside clauses in Background).

## Open Questions

<!-- Requirements-focused questions only (scope, acceptance criteria, business rules).
     Implementation questions go in implementation.md. -->

### RESOLVED: rigse cannot learn `clue_prepull` from the resolve answer
**Context**: R19 and R20 mint the CLUE class token when a package declares `clue_prepull`, and R17 says rigse learns about a package only from `GET /api/v1/packages/resolve`. REPORT-142's resolve answers `{catalog_id, identity, version, checksum, expected_duration_seconds, archived, runnable, reason}` (its implementation spec, the reading step): no `clue_prepull`, although it is a column of the `package_versions` row the resolve already joins. The list endpoint carries it, but only for each package's current version, and rigse must also run a non-current version.
**Options considered**:
- A) Amend REPORT-142's resolve to also answer `clue_prepull` from the version row. One field, no new query; rigse is the resolve's only consumer.
- B) rigse always mints the CLUE class token on every run. No cross-story change, but every run's `work/` document then holds a token able to read the class's CLUE documents, including runs of packages that never asked for them.
- C) rigse also calls `GET /api/v1/packages` and reads `clue_prepull` from each package's current version, refusing or guessing for a non-current version.

**Decision**: A (Doug, 2026-09-24). REPORT-142's R17 and its reading step were amended on its branch the same day: the resolve now answers `clue_prepull` from the resolved version's row. Recorded in R17 and R19.

### RESOLVED: Low confidence: the fingerprint's shape
**Context**: The story leaves the shape to this story, requiring only that it change when the assignment set changes. The profile document is a function of the URL list alone, so a fingerprint of the URLs would skip refreshes that produce an identical document, while a fingerprint of the offerings changes on exactly what the story names.
**Options considered**:
- A) A versioned hash of the sorted `(offering_id, url)` pairs: changes when an offering is added or removed or its URL changes.
- B) A versioned hash of the sorted distinct URLs: changes only when the profile's input changes.
- C) The latest `updated_at` among the offerings.

**Decision**: A, as `v1:` followed by the lowercase hex SHA-256 of the JSON array of `[offering_id, url]` pairs sorted by offering id, 67 characters. It meets the story's one requirement literally: B does not change when a second offering of an already-assigned activity is added or removed, which the story counts as the assignment set changing. The cost of A over B is a refresh that rewrites an identical profile in that case, which is one Cloud Task and is harmless because the deriver is idempotent (REPORT-142 R25). C misses a removal (a deleted offering leaves no `updated_at` behind) and changes on edits that do not touch the assignment set, such as reordering. Hashing JSON rather than a joined string keeps a URL containing the separator from colliding with two URLs; the `v1:` prefix lets a later shape change force one refresh everywhere instead of comparing unlike values. It is computed from the offerings R8 lists, including inactive ones and ones whose URL R11 leaves out of the refresh body, so the metadata endpoint and `refresh_profile` always agree. Recorded in R10.

### RESOLVED: Low confidence: which Firebase projects get a class token, and where rigse learns their names
**Context**: The spike took `firebase_project` and `firebase_apps` from the app. The story's body is packages only, and section 13 says which project holds CLUE is "runner and rigse configuration per environment". The runner requires `class_tokens[firebase_project]`.
**Options considered**:
- A) Two settings: the report-service FirebaseApp (always minted, also `firebase_project`) and the CLUE FirebaseApp (minted when `clue_prepull`).
- B) Derive the set from the FirebaseApp rows present.
- C) Keep taking the names from the app.

**Decision**: A. C contradicts the story's "takes `{packages}` and nothing else". B would mint a runner token in every Firebase project the portal happens to hold a key for (production portals hold keys for projects unrelated to the dashboard), which is exactly the unasked-for credential spread the runner claim exists to contain. The runner reads its own class token as `class_tokens[firebase_project]` and refuses a run without one (`researcher-dashboard/runner/server/runner.js:336-339`), so the report-service token is always minted; the CLUE token only when R20 says. The CLUE setting is the one RIGSE-369 deletes. Recorded in R19 and R29.

### RESOLVED: REPORT-141's `/run-package` validation expects a bare hex checksum
**Context**: REPORT-141's implementation spec validates `checksum` as "a hex string" (its queueing step), while REPORT-142 R9 and the resolve answer give `sha256:<lowercase hex>`, which is also what the runner computes and compares (`researcher-dashboard/runner/server/package-fetch.js:20`). rigse forwards the catalog's checksum verbatim (R17), so if REPORT-141 is built as written every run is refused 400.
**Options considered**:
- A) rigse sends the catalog's value unchanged, and REPORT-141's validation is corrected to `^sha256:[0-9a-f]{64}$`.
- B) rigse strips the `sha256:` prefix before sending, and the runner's comparison changes to match.

**Decision**: A for rigse's side, which needs no decision: the catalog, the runner and the design all use `sha256:<hex>`, and B would make rigse the one component rewriting a value it is supposed to carry untouched. REPORT-141's spec was the one in error. At stage 8, Doug approved correcting it (2026-09-24), and its R13 and queueing step now validate `^sha256:[0-9a-f]{64}$` and accept an assignment with `url: ""` and `name: null`, which R8 can send. Recorded in R17 and R22.

### RESOLVED: Judgment call: the endpoints accept only a launch token
**Context**: `check_for_auth_token` also accepts a session cookie, an HS256 portal token and an AccessGrant, none of which carries a scope.
**Options considered**:
- A) Refuse every credential but the launch token (R1).
- B) Accept any credential and take the class from the path for unscoped callers.

**Decision**: A. The story gates each endpoint on "the scope in the verified bearer", and `run_package` has no other way to name a class. Accepting a session would also make the two POSTs reachable by a cross-site form under `protect_from_forgery`'s null-session handling, and would give a portal session a path to mint runner tokens. The app is the only caller. Recorded as R1.

### RESOLVED: Judgment call: refuse unknown keys in the run body rather than ignore them
**Options considered**:
- A) 400 for any key but `packages`, and any entry key but `identity` and `version`.
- B) Read `identity` and `version` and ignore the rest.

**Decision**: A. The story says the body is those two fields "and nothing else" and that rigse must not accept a checksum or package key from the caller. Ignoring them would meet the letter, but refusing them makes a stale client that still sends a checksum fail loudly instead of appearing to choose its package bytes. Recorded as R16.

### RESOLVED: Judgment call: refuse an oversized assignment list rather than truncate it
**Options considered**:
- A) 422 without calling the function when the URL list exceeds REPORT-142's count or body limit.
- B) Send the first 500 sorted URLs.

**Decision**: A. A truncated list derives a profile that silently omits assignments, so packages matching them are silently not offered, which is the failure `final-design.md` 5.5 warns against. A class with more than 500 distinct assignment URLs, or 256 KiB of them, is far outside anything measured (35 activities gave 54 interactive URLs), and a visible refusal is the better failure for a case that should not happen. A single URL over 2,048 characters is left out instead, because refusing the whole class for one malformed row would deny every package to it. Recorded as R11 and R14.

### RESOLVED: Judgment call: the disabled 404 is a bare 404, not the error envelope
**Context**: R5 says the endpoints answer 404 while the dashboard is disabled "as the launch action does", and the launch action answers `head :not_found`. R28 says every refusal uses `API::APIController#error`. Found in the post-implementation comparison of the code with this spec.
**Options considered**:
- A) A bare 404, as the launch action gives and the plan's controller wrote.
- B) `error('The Researcher Dashboard is not enabled', 404)`, the envelope with a message.

**Decision**: A (implementation, 2026-09-24). A disabled dashboard is a portal on which the endpoints do not exist, not a refusal of a request to them, and a bare 404 is how such a portal already answers every path, including the launch. R28 governs the refusals of an enabled dashboard.

## Self-Review

Roles: Security Engineer, Senior Rails Engineer, QA Engineer, DevOps Engineer, and the engineer building RD-3 against these endpoints. Each finding was checked against the code, by reading it or by a throwaway spec, before it was recorded. Candidates dropped after checking:
- Forwarding the app's launch token to report-server's resolve. report-server is a designed verifier of the `researcher-dashboard` audience (REPORT-141 R5, REPORT-142 R15), so this hands the token to a service it was minted for.
- Class enumeration through the difference between 404 and 403. The class comes from the signed `scope_id`, not from anything the caller can vary, and `:id` must equal it (R4).
- `origins '*'` on the new CORS entry. rack-cors sends no credentials with a wildcard, and the endpoints refuse cookie sessions (R1).
- Repeated `refresh_profile` calls driving authoring fetches. Each needs a live launch token for a class the caller may research, and REPORT-142's worker is rate-limited (`maxConcurrentDispatches: 10`).
- Cohort names from projects the researcher holds no grant on. The spike returned the same names, and the Research Classes table the researcher launched from already lists them.

### Senior Rails Engineer

#### RESOLVED: R3 called the gate on `current_user`, which is nil for a launch-token request
The Devise strategy refuses every RS256 token (RIGSE-367 implementation, step 1: `decode_portal_token(jwt_token_value, aud: nil)` fails and leaves `current_user` nil), so the only user on these requests is the one `check_for_auth_token` returns from the token's `uid`. As written, R3 would have raised on nil or refused every call. Fixed: R3 and R7 name the token's user.

#### RESOLVED: R16's "exactly this body" cannot be checked against `params`
`config.load_defaults 7.0` turns on JSON parameter wrapping, so a scratch controller spec posting `{"packages": [...]}` saw `params.keys` of `packages, format, controller, action, researcher_dashboard` and `request.request_parameters.keys` of `packages, researcher_dashboard`. A top-level key check over either would refuse every valid request, and an unparsable body raised `ActionDispatch::Http::Parameters::ParseError` before the action. Fixed: R16 checks the parsed request body and names a non-object body as a 400.

### QA Engineer

#### RESOLVED: R4 compared a string path id with an integer claim
`params[:id]` is a string and `scope_id` an integer (RIGSE-367 R15), so a direct comparison refuses every request and a lenient one accepts `"12abc"`. Fixed: R4 compares as integers. (Stage 5 found the router already refuses a non-numeric id with a 404, `rails routes` showing `:id=>/\d+/` on the new routes, and R4 now says so.)

