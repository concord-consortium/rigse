# Peer-to-Peer Auth Removal — Research Findings

**Date:** 2026-02-26
**Status:** In Progress
**Related:** `portal-authentication-unification-design.md` Section 8 (Next Steps)

---

## Method

Searched the `concord-consortium` GitHub organization for:
- `learner_id_or_key` (unique to the peer-to-peer auth path)
- Code sending `Client.app_secret` as a Bearer token
- The `user_id` variant of peer-to-peer auth

## Findings

### Repos using `learner_id_or_key`

| Repository | Role | Uses `app_secret` as Bearer? | Notes |
|---|---|---|---|
| **rigse** | Server (defines the pattern) | N/A — validates incoming tokens | `api_controller.rb` lines 39-54 |
| **lara** | Client (sends peer tokens) | **Yes** | Multiple call sites (see below) |
| **activity-player** | Client (sends the param) | **No** — uses Portal JWT as Bearer | Transitional pattern |
| **report-service** | Client (fetches collaboration data) | **Yes** | `auto-importer.ts` — see below |

No other repos in the organization use `learner_id_or_key` or the `app_secret`-as-Bearer pattern for `check_for_auth_token` endpoints. However, the report-service uses `app_secret` as Bearer for the `collaborators_data` endpoint, which has its own `request_is_peer?` policy check.

### LARA's peer-to-peer auth usage

The design doc (Section 2.2) states: "LARA itself uses OAuth2 (not peer-to-peer) as documented in `docs/external-services.md` lines 51-54."

This is partially correct but incomplete. LARA uses **two** auth mechanisms:
- **OAuth2** for user-facing authentication (logging users in via the Portal)
- **Peer-to-peer** (`app_secret` as Bearer) for server-to-server communication

LARA sends `Bearer <app_secret>` in these production code paths:

| LARA code path | Purpose | Peer param sent |
|---|---|---|
| `lib/concord/auth_portal.rb` | Core auth helper — returns `'Bearer %s' % self.secret` | N/A (helper) |
| `app/services/portal_sender.rb` | Posts student answers back to Portal | `learner_id_or_key` |
| `app/controllers/api/v1/jwt_controller.rb` | Proxies JWT requests to Portal | `learner_id_or_key` (learner context) or `user_id` (non-learner context) |
| `app/services/create_collaboration.rb` | Fetches collaboration data from Portal | `learner_id_or_key` |
| `app/models/run.rb` | Provides auth token for run-specific requests | N/A (returns token) |

### Classification of LARA's peer-to-peer code paths

LARA is still running in production as an **authoring system**, but its student-facing runtime is no longer used directly. Deeper analysis of LARA's codebase reveals that **all outbound peer-to-peer auth is in student runtime or authoring plugin code**:

| Code path | Classification | Direction | Status |
|---|---|---|---|
| `portal_sender.rb` (answer posting) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `jwt_controller.rb` with `run_id` (JWT proxying, sends `learner_id_or_key`) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `jwt_controller.rb` without `run_id` (JWT proxying, sends `user_id`) | Authoring plugins | LARA → Portal | **Dead** — confirmed by log analysis. Added in LARA PR [#461](https://github.com/concord-consortium/lara/pull/461) (2019-08-27) for authoring plugin Firebase JWT access |
| `create_collaboration.rb` (collaboration) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `run.rb` / `runs_controller.rb` (admin detail) | Admin diagnostic | LARA → Portal | **Dead** — Portal logs show zero `/admin/learner_detail/` traffic over 365 days |

The two authoring-related uses of peer auth are **inbound** (Portal sends `Bearer <app_secret>` to LARA, not vice versa):
- `remote_duplicate_support.rb` — Portal calls LARA to copy an activity (likely disabled — broke and was not fixed)
- `import_controller.rb` — Portal calls LARA to import an activity

Critically, **activity publishing uses `user.authentication_token` (OAuth), not `app_secret`**. The LARA code in `publishable.rb` has an explicit comment: "The Portal API doesn't support auth_portal.secret authentication, so we switched to using user.authentication_token."

### Activity Player's usage

The Activity Player sends `learner_id_or_key` as a **query parameter** on `GET /api/v1/jwt/firebase` requests, but authenticates with `Authorization: Bearer/JWT <portalJWT>` (not `app_secret`). This means it does **not** use the peer-to-peer auth mechanism — the `Bearer/JWT` header matches Case D in `check_for_auth_token`, which extracts user identity from the JWT claims and never reads `learner_id_or_key`.

**Code path details** (from `concord-consortium/activity-player` source analysis):
- `src/portal-utils.ts` line 10: maps `portalData.learnerKey` to `{ learner_id_or_key: learnerKey }` and merges it into the query params for `getFirebaseJWT()`
- `src/portal-api.ts`: `getFirebaseJWT()` sends `GET {basePortalUrl}/api/v1/jwt/firebase?firebase_app=...&learner_id_or_key=...` with `Authorization: Bearer/JWT {portalJWT}`
- This code path is **actively used in production** — it runs every time an embedded interactive requests a Firebase JWT during an authenticated student session. There is no feature flag.

**Where `learnerKey` comes from — a bootstrap pattern:**
1. On page load, the Activity Player calls `getActivityPlayerFirebaseJWT()` which requests a Firebase JWT **without** `learner_id_or_key`
2. The Portal returns a Firebase JWT whose claims include a deprecated `returnUrl` field (e.g., `https://learn.concord.org/dataservice/external_activity_data/abc123`)
3. `getStudentLearnerKey()` extracts the last path segment of `returnUrl` as the learner key (only for student sessions)
4. This `learnerKey` is stored in `portalData` and included as `learner_id_or_key` on all **subsequent** Firebase JWT requests (triggered by embedded interactives via iframe-phone messaging)

So the value comes from an earlier Firebase JWT response, not from the same request — it's bootstrapped from the initial JWT exchange. However, since the Portal ignores `learner_id_or_key` on all requests authenticated via `Bearer/JWT`, this parameter has no effect. It is likely a vestigial pattern inherited from LARA's peer-to-peer auth approach, where the parameter was consumed by Case B in `check_for_auth_token` to establish learner context.

**The Portal ignores this parameter.** The JWT controller's `handle_initial_auth` calls `check_for_auth_token(params)`, but the `Bearer/JWT` header matches the JWT auth path (Case D), which extracts user/role from JWT claims. Neither `handle_initial_auth` nor the `firebase` action reads `learner_id_or_key` from params — they use `resource_link_id`, `target_user_id`, `class_hash`, etc. The `learner_id_or_key` parameter flows through in the params hash but is never accessed. This was true both before and after the peer-to-peer auth removal.

**Interactives/plugins that request Firebase JWTs via the Activity Player (2026-02-26):**

Searched the `concord-consortium` GitHub org for `getFirebaseJWT` and `firebaseJWT`. The iframe-phone protocol uses `"getFirebaseJWT"` (request from interactive to host) and `"firebaseJWT"` (response from host to interactive). Interactives either use the `@concord-consortium/lara-interactive-api` client library or raw `iframe-phone` calls. Plugins use `@concord-consortium/lara-plugin-api` (`context.getFirebaseJwt()`), where the host provides the JWT via the plugin context.

**Interactives** (embedded in iframe, request JWT from host via iframe-phone):

| Repo | firebase_app | Method | Uses JWT for | Production traffic (365 days) | Last commit | Active? |
|---|---|---|---|---|---|---|
| `question-interactives` | (unknown) | `@concord-consortium/lara-interactive-api` | Firestore (student settings) + Token Service | 0 requests with `learner_id_or_key` | Feb 2026 | Yes |
| `erosion-interactive` | `ep-erosion-dev` | `@concord-consortium/lara-interactive-api` | Firestore | 248 requests | Jul 2024 | No |
| `vortex` (runtime mode) | `vortex` | `@concord-consortium/lara-interactive-api` | Firebase RTDB | 2 requests | Aug 2024 | No |
| `fb-weather-demo` | (unknown) | Raw iframe-phone (pre-library) | Firebase RTDB | 0 requests with `learner_id_or_key` | May 2024 | No |
| `teaching-teamwork` | (unknown) | Raw iframe-phone (pre-library) | Firebase RTDB | 0 requests with `learner_id_or_key` | May 2024 | No |

**Plugins** (run alongside interactives, host provides JWT via plugin context):

| Repo | firebase_app | Uses JWT for | Production traffic (365 days) | Last commit | Active? |
|---|---|---|---|---|---|
| `glossary-plugin` | `glossary-plugin` | Firestore + Token Service | 851 requests | May 2025 | Somewhat |
| `lara-sharing-plugin` | (unknown) | Firestore (shared state) | 0 requests with `learner_id_or_key` | May 2024 | No |
| `lara-debugging-plugin` | (unknown) | Display/debugging only | 0 requests with `learner_id_or_key` | Oct 2020 | No |

Note: Production traffic counts are from the 365-day Portal log search for `learner_id_or_key` on `GET /api/v1/jwt/firebase`, broken down by `firebase_app` parameter. Only glossary-plugin (851), ep-erosion-dev (248), and vortex (2) had any traffic. The "0 requests" entries mean no requests with `learner_id_or_key` were found — these interactives/plugins may still request Firebase JWTs without `learner_id_or_key` (e.g., on the initial page-load request).

**Hosts** (handle `"getFirebaseJWT"` messages, call Portal API):

| Repo | Notes |
|---|---|
| `activity-player` | Primary modern host |
| `lara` | Original host (student runtime dead); also publishes the `@concord-consortium/lara-interactive-api` client library |
| `portal-report` | Host for report-mode interactives |
| `question-interactives` | Sub-host — carousel/side-by-side/scaffolded-question re-proxy to nested child iframes |

**Services** (call Portal API directly, not via iframe-phone — these do **not** trigger the `learner_id_or_key` code path):

| Repo | Notes |
|---|---|
| `collaborative-learning` | Top-level app, not embedded in iframe |
| `report-service` | Researcher reports |
| `token-service` | Example app only |

Production logs confirm that `glossary-plugin` (851 requests), `erosion-interactive` (248), and `vortex` (2) are the only interactives/plugins that triggered the `learner_id_or_key` code path over the past year. Notably, `question-interactives` — the most actively maintained interactive — had zero requests with `learner_id_or_key` despite being actively developed.

### Report-service's peer-to-peer auth usage (ACTIVE)

The report-service's `auto-importer` Cloud Function (`functions/src/auto-importer.ts`) uses peer-to-peer auth to fetch collaboration data from the Portal. This is **active production traffic**.

**How it works:**
1. The Activity Player creates a collaboration on the Portal via `POST /api/v1/collaborations`, which returns a `collaborators_data_url` (e.g., `https://learn.concord.org/api/v1/collaborations/129848/collaborators_data`)
2. The Activity Player stores this URL in each student answer written to Firebase (`ltiAnswer.collaborators_data_url`)
3. The report-service's `auto-importer` detects new/updated answers via Firestore triggers. When an answer has a `collaborators_data_url`, the auto-importer fetches it to discover all collaborators and replicate the answer to each collaborator's parquet file in S3

**Code path** (`functions/src/auto-importer.ts`):
```typescript
const fetchCollaborationData = async (collaboratorsDataUrl: string, portalSecret: string) => {
  const resp = await axios.get(collaboratorsDataUrl, {
    headers: {"Authorization": `Bearer ${portalSecret}`},
  });
```

The `portalSecret` is a Client `app_secret` — this is peer-to-peer auth, gated by `CollaborationPolicy#collaborators_data?` → `request_is_peer?` on the Portal side.

**Which Client?** The report-service has three Portal Clients (IDs 27, 28, 31). The `portalSecret` is configured per-portal in the report-service's Firebase environment. One of these Client `app_secret` values is used as the Bearer token.

**Production traffic (Logs Insights, 365 days):** 1,092 GET requests to `/api/v1/collaborations/:id/collaborators_data`. All from GCP IPs (`34.96.x.x`, `34.34.233.x`) — consistent with GCP Cloud Functions. Monthly distribution:

| Month | Requests |
|-------|----------|
| Feb 2026 | 48 |
| Jan 2026 | 19 |
| Dec 2025 | 34 |
| Nov 2025 | 56 |
| Oct 2025 | 148 |
| Sep 2025 | 135 |
| Aug 2025 | 18 |
| Jul 2025 | 12 |
| Jun 2025 | 23 |
| May 2025 | ~211 |
| Apr 2025 | 168 |
| Mar 2025 | ~208 |
| Feb 2025 | 12 |

Traffic correlates with the school year (higher Sep–Nov, Apr–May; lower in summer/winter breaks).

### Portal-side policy dependencies

The Portal's Pundit policies also check for peer auth:

- `ApplicationPolicy#request_is_peer?` (lines 153-158) — enumerates all Client `app_secret` values and checks if the Bearer token matches any
- `API::V1::CollaborationPolicy` (lines 31-36) — duplicates the same check, gates `collaborators_data?`

The `collaborators_data?` policy is **actively used** by the report-service (see above). The `request_is_peer?` check in `ApplicationPolicy` may also be used elsewhere; further analysis needed.

### Production Client cross-reference

There are 25 Clients configured on the production Portal. Cross-referencing with the GitHub search results:

**LARA clients (only known peer-to-peer consumers):**

| ID | Name | site_url | GitHub repo | Peer-to-peer status |
|---|---|---|---|---|
| 2 | authoring | `authoring.concord.org` | `concord-consortium/lara` | All outbound peer auth is in dead student runtime code |
| 3 | authoring-staging | (none) | `concord-consortium/lara` | Staging — same code as production |
| 4 | authoring-dev | (none) | `concord-consortium/lara` | Dev — same code as production |

**All other Clients — no peer-to-peer auth usage found:**

| ID | Name | site_url | GitHub repo |
|---|---|---|---|
| 1 | localhost | (none) | Portal internal (`rigse`) |
| 7 | CODAP Document Server | (none) | `concord-consortium/document-store` |
| 9 | document-store-inquiryspace | (none) | `concord-consortium/document-store` |
| 11 | admin_api_user_client | (none) | Portal internal (`rigse` rake task) |
| 12 | DEFAULT_REPORT_SERVICE_CLIENT | (none) | Portal internal (`rigse` rake task) |
| 13 | Concord GH Pages | `concord-consortium.github.io/HASDashboard/` | `concord-consortium/HASDashboard` |
| 14 | external reports | (none) | Portal internal (`rigse` ExternalReport) |
| 15 | Weather Dashboard | `weather.concord.org` | `concord-consortium/weather` |
| 16 | CollabSpace Dashboard | `workspaces.concord.org` | `concord-consortium/collabspace` |
| 17 | dataflow | `dataflow.concord.org` | `concord-consortium/flow-server` |
| 18 | AWS Learner Logs | (none) | `concord-consortium/aws-learner-logs` |
| 19 | Digital Inscriptions Dashboard | (none) | `concord-consortium/digital-inscriptions` |
| 20 | Geniventure Dashboard | (none) | `concord-consortium/geniventure-dashboard` |
| 21 | Glossary Authoring | (none) | `concord-consortium/glossary-plugin` |
| 22 | model-my-watershed | `modelmywatershed.org` | `WikiWatershed/model-my-watershed` (external org) |
| 23 | vortex | `models-resources.concord.org/vortex/` | `concord-consortium/vortex` |
| 26 | Portal Report SPA | `portal-report.concord.org` | `concord-consortium/portal-report` |
| 27 | Athena Researcher Reports | `researcher-reports.concord.org/` | `concord-consortium/report-service` |
| 28 | Report Service Collaboration | (none) | `concord-consortium/report-service` |
| 29 | Activity Player | `activity-player.concord.org/` | `concord-consortium/activity-player` |
| 30 | CLUE | `collaborative-learning.concord.org/` | `concord-consortium/collaborative-learning` |
| 31 | Research Report Server | `report-server.concord.org/` | `concord-consortium/report-service` |

**CORRECTION:** The initial GitHub org search missed the report-service's peer auth usage because it searched for `app_secret` as a literal string, not for the pattern of sending a secret as a Bearer token. The report-service stores the portal secret in Firebase config (not as `app_secret` in source), so the search didn't flag it. The `collaborators_data` log search (see Report-service section above) revealed this active usage.

The report-service Clients (IDs 27, 28, 31) **do use `app_secret` as Bearer** for the `collaborators_data` endpoint. All other Clients use standard OAuth2 or Bearer token flows.

Notes:
- 4 clients are Portal-internal (IDs 1, 11, 12, 14) — created by rake tasks or internal features within `rigse`
- 3 clients map to `report-service` (IDs 27, 28, 31) — different subdirectories of the same monorepo; **at least one uses peer auth for `collaborators_data`**
- 2 clients map to `document-store` (IDs 7, 9) — different instances of the same codebase
- ID 22 (`model-my-watershed`) is the only client outside the `concord-consortium` org

## Log Verification

### LARA production logs (verified 2026-02-26)

Scanned ~27M LARA production log records (~7.5GB) across 90 days:
- **Zero** JWT proxy requests (non-Firebase) to the Portal
- **Zero** collaboration endpoint requests
- **Zero** outbound PortalSender answer posts
- The only `/api/v1/jwt` traffic was Firebase JWT requests (`get_firebase_jwt`), which is a separate code path that does not use peer-to-peer `app_secret` auth
- 15 matches for `external_activity_data` were all inbound page loads with `returnUrl` query params, not outbound POSTs

### Portal production logs

Searched Portal production logs (`learn-ecs-production`). Initial search used CloudWatch `filter-log-events` (90-day window); expanded to CloudWatch Logs Insights (365-day window) after discovering the initial methodology missed results.

**`learner_id_or_key` — VERIFIED (Logs Insights, 365 days):**
1,101 requests, **all on `GET /api/v1/jwt/firebase`**. Source code analysis indicates these come from the Activity Player using `Bearer/JWT` auth (not peer-to-peer), though the logs do not reveal the auth type directly (see Activity Player section above). Breakdown: glossary-plugin (851), ep-erosion-dev (248), vortex (2). No occurrences on any peer-to-peer endpoint. Monthly distribution: Mar 2025 (4), Apr (509), May (128), Jul (1), Sep (31), Oct (100), Nov (251), Feb 2026 (77).

**`user_id=` as query parameter — VERIFIED (Logs Insights, 365 days):**
Searched for `?user_id=` and `&user_id=` in `Started GET/POST/PUT/DELETE` lines across all `/api/v1/` endpoints. This matches `user_id` as a proper query parameter while excluding substring matches like `target_user_id=`. Results:

| Endpoint | Requests | Peer-to-peer? |
|---|---|---|
| `/api/v1/offerings` | 930,920 | **No** — see below |
| `/api/v1/jwt` | 0 | — |
| `/api/v1/bookmarks` | 0 | — |
| `/api/v1/external_activities` | 0 | — |
| `/api/v1/teacher_classes` | 0 | — |
| all other `/api/v1/` endpoints | 0 | — |

The 930,920 offerings requests cannot be definitively classified as OAuth vs. peer-to-peer from the logs alone — Rails does not log the `Authorization` header or the referer. ALB access logs (which would include the referer) are not enabled on the Portal load balancers (`learn-ELBv2-I2UXANP07DD5`, `learn-ELBv2-1Q7V4OJM2B6UI`). SQL query logging is also unavailable (production uses `:info` log level; `Client.find_by_app_secret` queries would only appear at `:debug`).

However, multiple lines of evidence indicate these are not peer-to-peer:

1. **Git history:** The `user_id` peer-to-peer path was added in Portal PR [#682](https://github.com/concord-consortium/rigse/pull/682) (commit `07a839e96`, 2019-08-27, Pivotal `#168138043`). The PR comment links to LARA PR [#461](https://github.com/concord-consortium/lara/pull/461), which shows it was created specifically for **LARA authoring plugins** — allowing plugins like `glossary-plugin` to get Firebase JWTs during authoring mode (no student run). LARA's `get_firebase_jwt` action sends `user_id=session[:portal_user_id]` (instead of `learner_id_or_key`) when there is no run. The only Portal endpoint this targets is `/api/v1/jwt/firebase`, not `/api/v1/offerings`.
2. **GitHub org search:** No codebase outside of LARA sends `app_secret` as a Bearer token.
3. **LARA's peer-to-peer `user_id` usage is in dead student runtime code** — confirmed by LARA log analysis (zero outbound peer-to-peer traffic over 90 days).
4. **The offerings controller uses `user_id` as a query filter**, not for authentication. The `index` action (line 79) reads `params[:user_id]` to filter which teacher's offerings to return; authentication is handled separately by `authorize` and `current_user` from the session/OAuth token.
5. **Volume:** ~930K requests/year is consistent with normal application traffic (teacher dashboards polling for offerings), not peer-to-peer server calls.

**`/collaborators_data` — ACTIVE TRAFFIC (Logs Insights, 365 days):**
1,092 GET requests to `/api/v1/collaborations/:id/collaborators_data`. All source IPs are GCP ranges (`34.96.x.x`, `34.34.233.x`), identified as the report-service's `auto-importer` Cloud Function (see Report-service section above). This endpoint uses `request_is_peer?` policy — the report-service authenticates with `Bearer <portalSecret>` (a Client `app_secret`). **This is active peer-to-peer auth traffic.**

**`/admin/learner_detail/` — VERIFIED (Logs Insights, 365 days):**
Searched `learn-ecs-production` log group over 365 days. Query: `filter @message like /learner_detail/`. Scanned 635,612,653 records (~80 GB). **Zero matches.** This confirms no traffic to `/admin/learner_detail/` over the past year — safe to deploy.

## Conclusion

**Peer-to-peer auth in `check_for_auth_token` (Cases B and C) can be removed** — no traffic uses that code path. However, **the `request_is_peer?` policy check used by `collaborators_data` is actively used and cannot be removed.**

**Evidence that `check_for_auth_token` peer auth is dead:**
- LARA production logs confirm zero traffic to JWT proxy, collaboration, and answer posting endpoints over 90 days
- Portal production logs over 365 days show 1,101 `learner_id_or_key` requests, but **all on `GET /api/v1/jwt/firebase`** (glossary-plugin, ep-erosion-dev, vortex). Source code analysis indicates these come from the Activity Player using `Bearer/JWT` auth (logs do not reveal auth type directly). **Zero occurrences on any peer-to-peer endpoint.**
- Portal `user_id=` search (Logs Insights, 365 days): only `/api/v1/offerings` has traffic (930,920 requests). Zero `user_id=` requests on `/api/v1/jwt`, `/api/v1/bookmarks`, `/api/v1/external_activities`, or `/api/v1/teacher_classes`. The offerings requests are not peer-to-peer: git history shows the `user_id` peer path was added only for LARA's `/api/v1/jwt/firebase` proxy (PR [#682](https://github.com/concord-consortium/rigse/pull/682)), the offerings controller uses `user_id` as a query filter (not auth), and the volume (~930K/year) matches normal teacher dashboard traffic
- Activity publishing uses OAuth tokens, not `app_secret`
- The Activity Player uses Portal JWTs, not `app_secret`, for the `learner_id_or_key` parameter

**Evidence that `collaborators_data` peer auth is ACTIVE:**
- 1,092 requests over 365 days from the report-service's `auto-importer` Cloud Function (GCP IPs)
- The report-service sends `Authorization: Bearer <portalSecret>` where `portalSecret` is a Client `app_secret` (`functions/src/auto-importer.ts` line 280)
- Traffic is ongoing (48 requests in Feb 2026) and correlates with the school year
- Removing `request_is_peer?` or the `collaborators_data` policy would break collaborative activity reporting in the report-service

## Open Questions

(No remaining open questions — all have been resolved.)

## Resolved Questions

### Is `run.rb` / `runs_controller.rb` actually dead or just "rarely used"?

**Answer: Dead — confirmed by existing log analysis in this document.**

LARA's `run.rb` provides `lara_to_portal_secret_auth` which generates a `Bearer <app_secret>` token. This token is used in two code paths that make **actual outbound HTTP requests** (not just display tokens):

1. **`remote_info`** in `runs_controller.rb` — an admin-only action (`authorize! :inspect, Run`) that makes an HTTParty GET to the Portal's `/admin/learner_detail/:id.txt` with `Authorization: Bearer <app_secret>`. The Portal log search (Logs Insights, 365 days) found **zero matches** for `/admin/learner_detail/` (see Log Verification section above).
2. **`send_to_portal`** — delegates to `PortalSender` to POST student answers. Already classified as "Dead" in the findings table and confirmed by LARA log analysis (zero outbound PortalSender traffic over 90 days).

The "Rarely used" classification in the findings table should be upgraded to **Dead — confirmed by log analysis**.

### Does the `republish` endpoint receive any peer-auth traffic?

**Answer: No — the `republish` action was deleted. The endpoint is dead code.**

Both the `publish` and `republish` actions were **deleted** from `ExternalActivitiesController` in commit `31a593e2a` (2023-03-10, same legacy code cleanup that removed `duplicate`). The routes on `routes.rb:277-278` are orphaned — any POST to `/external_activities/republish/:version` would fail with `AbstractController::ActionNotFound`. The `ExternalActivityPolicy#republish?` policy (line 16) and the `pundit_user_not_authorized` handler for `'republish?'` (line 7) are also dead code. No log search is needed — the endpoint cannot receive traffic.

### Does `model-my-watershed` (Client ID 22, external org) use peer-to-peer auth?

**Answer: No. The repo uses Django REST Framework token auth — completely unrelated to the Portal's peer-to-peer pattern.**

Searched the `WikiWatershed/model-my-watershed` GitHub repo for `app_secret`, `Bearer`, `learner_id_or_key`, and `concord`. Zero results for all terms. The codebase uses Django REST Framework's built-in token authentication (see [ADR-005](https://github.com/WikiWatershed/model-my-watershed/blob/master/doc/arch/adr-005-api-client-app-auth.md)), which is a self-contained token system with no integration to the Concord Portal's auth mechanisms.

### Is the Portal's remote copy/import feature (which calls LARA via peer auth) still enabled?

**Answer: The remote copy feature is broken; the import feature has surviving code but is admin-only and irrelevant to inbound peer-auth removal.**

**Remote copy (duplicate):** The `ExternalActivity#duplicate` method — including `duplicate_on_remote`, which sent `Bearer <app_secret>` to LARA's `/remote_duplicate` endpoint — was **deleted** in commit `31a593e2a` (2023-03-10, "Remove lots of legacy code related to activity structure"). The `copy` controller action and route still exist (`external_activities_controller.rb:249`), but calling `@external_activity.duplicate(current_visitor, root_url)` would raise a `NoMethodError` at runtime. The "Copy" button may still appear in the UI for some materials (the `external_copyable` check in `data_helpers.rb:314` still gates on `tool.remote_duplicate_url`), but clicking it crashes. **This feature has been non-functional for ~3 years.**

**Import:** The `Import::ImportExternalActivity` job (`rails/app/models/import/import_external_activity.rb:59-68`) still contains code that sends `Bearer <app_secret>` to LARA's `/import/import_portal_activity` endpoint. This is an admin-only feature (gated by `admin_only` in `imports_controller.rb:309`). However, it targets a LARA endpoint that would need to be responsive, and all LARA student runtime traffic is confirmed dead.

**Impact on peer-to-peer auth removal:** Neither feature is relevant. Both are **outbound** (Portal→LARA), not inbound (LARA→Portal). Removing peer-to-peer auth from the Portal's inbound API controllers does not affect these code paths. The remote copy code is already dead; the import code is a separate cleanup item if desired.

### Does the `collaborators_data` endpoint receive any peer-auth traffic?

**Answer: Yes — the report-service's `auto-importer` actively uses peer auth on this endpoint.**

Portal-side Logs Insights search (365 days) found 1,092 GET requests to `/api/v1/collaborations/:id/collaborators_data`, all from GCP IPs (`34.96.x.x`, `34.34.233.x`). Source code analysis of `concord-consortium/report-service` (`functions/src/auto-importer.ts`) confirmed the caller: the `fetchCollaborationData` function sends `Authorization: Bearer ${portalSecret}` where `portalSecret` is a Client `app_secret`. The auto-importer fetches collaboration data to replicate student answers to all collaborators' parquet files in S3. Traffic is ongoing and correlates with the school year.

**Impact on peer-to-peer auth removal:** The `request_is_peer?` policy check in `CollaborationPolicy#collaborators_data?` **cannot be removed** without first migrating the report-service to a different auth mechanism. The `check_for_auth_token` code in `api_controller.rb` (Cases B and C) is a separate code path and can still be removed independently — the `collaborators_data` endpoint does not use `check_for_auth_token`.
