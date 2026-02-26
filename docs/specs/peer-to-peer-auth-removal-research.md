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

No other repos in the organization use `learner_id_or_key` or the `app_secret`-as-Bearer pattern.

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

LARA is still running in production as an **authoring system**, but its student-facing runtime is no longer used directly. Deeper analysis of LARA's codebase reveals that **all outbound peer-to-peer auth is in student runtime code**:

| Code path | Classification | Direction | Status |
|---|---|---|---|
| `portal_sender.rb` (answer posting) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `jwt_controller.rb` (JWT proxying) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `create_collaboration.rb` (collaboration) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `run.rb` / `runs_controller.rb` (admin detail) | Admin diagnostic | LARA → Portal | Rarely used |

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

### Portal-side policy dependencies

The Portal's Pundit policies also check for peer auth:

- `ApplicationPolicy#request_is_peer?` (lines 153-158) — enumerates all Client `app_secret` values and checks if the Bearer token matches any
- `API::V1::CollaborationPolicy` (lines 31-36) — duplicates the same check, gates `collaborators_data?`

These would need to be updated or removed if peer-to-peer auth is deprecated.

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

None of these Clients' corresponding codebases were found to use `app_secret` as a Bearer token in the GitHub org search. They all use standard OAuth2 or Bearer token flows.

Notes:
- 4 clients are Portal-internal (IDs 1, 11, 12, 14) — created by rake tasks or internal features within `rigse`
- 3 clients map to `report-service` (IDs 27, 28, 31) — different subdirectories of the same monorepo
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

**`user_id` searches — UNVERIFIED (used flawed `filter-log-events` methodology):**
The following results were obtained with the same `filter-log-events` approach that produced false "zero results" for `learner_id_or_key`. They should be re-run with Logs Insights before being relied upon:
- `user_id` + `/api/v1/jwt`: false positives only — matches were `target_user_id` (substring match)
- `user_id` + `/api/v1/bookmarks`: zero results
- `user_id` + `/api/v1/external_activities`: zero results
- `user_id` + `/api/v1/offerings`: frequent hits, but assessed as normal OAuth query parameter filters
- `user_id` + `/api/v1/teacher_classes`: zero results

**`/admin/learner_detail/` — VERIFIED (Logs Insights, 365 days):**
Searched `learn-ecs-production` log group over 365 days. Query: `filter @message like /learner_detail/`. Scanned 635,612,653 records (~80 GB). **Zero matches.** This confirms no traffic to `/admin/learner_detail/` over the past year — safe to deploy.

## Conclusion

**Peer-to-peer auth can be removed.** Evidence:
- No repos outside of LARA use `app_secret` as a Bearer token
- No production Clients other than the LARA clients (2, 3, 4) show evidence of peer-to-peer usage
- LARA production logs confirm zero traffic to JWT proxy, collaboration, and answer posting endpoints over 90 days
- Portal production logs over 365 days show 1,101 `learner_id_or_key` requests, but **all on `GET /api/v1/jwt/firebase`** (glossary-plugin, ep-erosion-dev, vortex). Source code analysis indicates these come from the Activity Player using `Bearer/JWT` auth (logs do not reveal auth type directly). **Zero occurrences on any peer-to-peer endpoint.**
- Portal `user_id` log searches used the flawed `filter-log-events` methodology and need to be re-verified with Logs Insights (see Log Verification section)
- Activity publishing uses OAuth tokens, not `app_secret`
- The Activity Player uses Portal JWTs, not `app_secret`, for the `learner_id_or_key` parameter

## Open Questions

1. **Is the Portal's remote copy/import feature (which calls LARA via peer auth) still enabled?** If disabled, the inbound peer-auth endpoints on LARA are also dead. This is low-priority since the direction is Portal→LARA (inbound to LARA), not LARA→Portal.

2. **Re-run `user_id` Portal log searches with Logs Insights.** The original searches used the flawed `filter-log-events` methodology. Endpoints to re-verify: `/api/v1/jwt`, `/api/v1/bookmarks`, `/api/v1/external_activities`, `/api/v1/offerings`, `/api/v1/teacher_classes`.
