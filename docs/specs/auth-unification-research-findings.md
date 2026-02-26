# Auth Unification — Research Findings

**Date:** 2026-02-26
**Status:** In Progress
**Related:** `portal-authentication-unification-design.md` Section 8 (Next Steps)

---

## Research Task 1: Can Peer-to-Peer Auth Be Removed?

### Method

Searched the `concord-consortium` GitHub organization for:
- `learner_id_or_key` (unique to the peer-to-peer auth path)
- Code sending `Client.app_secret` as a Bearer token
- The `user_id` variant of peer-to-peer auth

### Findings

#### Repos using `learner_id_or_key`

| Repository | Role | Uses `app_secret` as Bearer? | Notes |
|---|---|---|---|
| **rigse** | Server (defines the pattern) | N/A — validates incoming tokens | `api_controller.rb` lines 39-54 |
| **lara** | Client (sends peer tokens) | **Yes** | Multiple call sites (see below) |
| **activity-player** | Client (sends the param) | **No** — uses Portal JWT as Bearer | Transitional pattern |

No other repos in the organization use `learner_id_or_key` or the `app_secret`-as-Bearer pattern.

#### LARA's peer-to-peer auth usage

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

#### Classification of LARA's peer-to-peer code paths

LARA is still running in production as an **authoring system**, but its student-facing runtime is no longer used directly. Deeper analysis of LARA's codebase reveals that **all outbound peer-to-peer auth is in student runtime code**:

| Code path | Classification | Direction | Status |
|---|---|---|---|
| `portal_sender.rb` (answer posting) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `jwt_controller.rb` (JWT proxying) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `create_collaboration.rb` (collaboration) | Student runtime | LARA → Portal | **Dead** — confirmed by log analysis |
| `run.rb` / `runs_controller.rb` (admin detail) | Admin diagnostic | LARA → Portal | Rarely used |

**LARA log verification (2026-02-26):** Scanned ~27M LARA production log records (~7.5GB) across 90 days:
- **Zero** JWT proxy requests (non-Firebase) to the Portal
- **Zero** collaboration endpoint requests
- **Zero** outbound PortalSender answer posts
- The only `/api/v1/jwt` traffic was Firebase JWT requests (`get_firebase_jwt`), which is a separate code path that does not use peer-to-peer `app_secret` auth
- 15 matches for `external_activity_data` were all inbound page loads with `returnUrl` query params, not outbound POSTs

**Portal log verification (2026-02-26):** Searched Portal production logs for peer-to-peer auth parameters across 90 days:
- `learner_id_or_key`: **zero results** (definitive — this parameter is unique to peer-to-peer auth)
- `user_id` + `/api/v1/jwt`: false positives only — matches were `target_user_id` (substring match), normal Firebase JWT requests
- `user_id` + `/api/v1/bookmarks`: zero results
- `user_id` + `/api/v1/external_activities`: zero results
- `user_id` + `/api/v1/offerings`: frequent hits, but these are normal OAuth-authenticated query parameter filters (e.g., teacher fetching their offerings), not peer-to-peer auth
- `user_id` + `/api/v1/teacher_classes`: zero results

The two authoring-related uses of peer auth are **inbound** (Portal sends `Bearer <app_secret>` to LARA, not vice versa):
- `remote_duplicate_support.rb` — Portal calls LARA to copy an activity (likely disabled — broke and was not fixed)
- `import_controller.rb` — Portal calls LARA to import an activity

Critically, **activity publishing uses `user.authentication_token` (OAuth), not `app_secret`**. The LARA code in `publishable.rb` has an explicit comment: "The Portal API doesn't support auth_portal.secret authentication, so we switched to using user.authentication_token."

#### Activity Player's usage

The Activity Player (`src/portal-utils.ts`) sends `learner_id_or_key` as a parameter when requesting Firebase JWTs from the Portal, but authenticates with a **Portal JWT** (not `app_secret`) as the Bearer token. This means it uses the `learner_id_or_key` parameter name but does **not** use the peer-to-peer auth mechanism — it goes through the standard JWT auth path (Case D in `check_for_auth_token`).

#### Portal-side policy dependencies

The Portal's Pundit policies also check for peer auth:

- `ApplicationPolicy#request_is_peer?` (lines 153-158) — enumerates all Client `app_secret` values and checks if the Bearer token matches any
- `API::V1::CollaborationPolicy` (lines 31-36) — duplicates the same check, gates `collaborators_data?`

These would need to be updated or removed if peer-to-peer auth is deprecated.

#### Production Client cross-reference

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

#### Conclusion

**Peer-to-peer auth can be removed.** Evidence:
- No repos outside of LARA use `app_secret` as a Bearer token
- No production Clients other than the LARA clients (2, 3, 4) show evidence of peer-to-peer usage
- LARA production logs confirm zero traffic to JWT proxy, collaboration, and answer posting endpoints over 90 days
- Portal production logs confirm zero `learner_id_or_key` requests over 90 days (this parameter is unique to peer-to-peer auth)
- Portal `user_id` on `/api/v1/offerings` is normal OAuth traffic (query parameter filter), not peer-to-peer auth — confirmed by the absence of `learner_id_or_key`
- Activity publishing uses OAuth tokens, not `app_secret`
- The Activity Player uses Portal JWTs, not `app_secret`, for the `learner_id_or_key` parameter

### Remaining Open Questions

1. **Is the Portal's remote copy/import feature (which calls LARA via peer auth) still enabled?** If disabled, the inbound peer-auth endpoints on LARA are also dead. This is low-priority since the direction is Portal→LARA (inbound to LARA), not LARA→Portal.

2. **Verify zero traffic to `/admin/learner_detail/` before peer auth removal is deployed.** The `LearnerDetailPolicy#show?` was gated by `request_is_peer?` (now returns `false`). Unlike the `check_for_auth_token` peer paths, this endpoint doesn't use `learner_id_or_key` or `user_id` params — it only requires a Bearer token matching any Client's `app_secret`. So the Portal log searches for those params would not have caught traffic to this endpoint. The GitHub org search found no repos other than LARA using `app_secret` as a Bearer token, and LARA's related code path (`run.rb` / `runs_controller.rb` — admin diagnostic) was classified as "Rarely used." However, the route (`GET /admin/learner_detail/:id_or_key.:format`) should be searched for directly in Portal request logs to confirm zero traffic over 90 days before deploying.

   **AWS CLI commands to verify** (CloudWatch Logs, `us-east-1`, stream prefix `portal`):

   Replace `<LOG_GROUP>` with the Portal production CloudWatch log group name (the `CloudWatchLogGroup` stack parameter).

   ```bash
   # Search for any request to the learner_detail endpoint over the last 90 days.
   # The route is GET /admin/learner_detail/:id_or_key.:format so "learner_detail"
   # in a request path is unambiguous.
   aws logs filter-log-events \
     --log-group-name "<LOG_GROUP>" \
     --log-stream-name-prefix "portal" \
     --start-time $(date -d '90 days ago' +%s)000 \
     --filter-pattern '"learner_detail"' \
     --region us-east-1 \
     --output text

   # If the above returns results, narrow to actual HTTP requests (vs. other log lines)
   # by filtering for the path pattern:
   aws logs filter-log-events \
     --log-group-name "<LOG_GROUP>" \
     --log-stream-name-prefix "portal" \
     --start-time $(date -d '90 days ago' +%s)000 \
     --filter-pattern '"GET" "learner_detail"' \
     --region us-east-1 \
     --output text
   ```

   Expected result: zero matches confirms safe to deploy.

---

## Research Task 2: Can Client-less Grants Be Replaced with JWTs?

### Method

The design doc identifies exactly 2 creation sites for client-less grants (Section 2.1). Both create 3-minute tokens with a learner but no client:

1. `app/models/external_activity.rb:150` — launch tokens for external activities
2. `app/services/api/v1/create_collaboration.rb:82` — collaboration tokens

### Findings

The creation sites are confirmed. Both call `User#create_access_token_with_learner_valid_for` which creates an `AccessGrant` with `learner_id` but no `client_id`.

The tokens are passed to external runtimes as URL parameters (`?token=...`). The runtime sends them back as `Authorization: Bearer <token>` to call Portal APIs. For Option B (replacing with JWTs) to work, the runtimes must treat the token as opaque — they must not make assumptions about its format (e.g., length, character set, absence of dots).

#### Runtimes receiving client-less tokens

Production query (`ExternalActivity.where(append_auth_token: true)`) returned these distinct hostnames:

| Hostname | Status | Needs verification? |
|---|---|---|
| **activity-player.concord.org** | Active | Yes — verified below |
| **collaborative-learning.concord.org** | Active | Yes — verified below |
| **geniventure.concord.org** | Active | Yes — verified below |
| activity-player-offline.concord.org | Inactive — last launch May 2021 | No — not in use |
| collabspace.concord.org | Replaced by collaborative-learning | No — OK to break |
| workspaces.concord.org | Replaced by collaborative-learning | No — OK to break |
| dataflow-app.concord.org | Inactive — modern version is inside collaborative-learning | No — OK to break |
| 127.0.0.1 / localhost | Dev/test only | No |
| nil | Missing URL | No |

#### Runtime token handling verification

All three active runtimes treat the Portal bearer token as **fully opaque**:

**activity-player** (repo: `concord-consortium/activity-player`)
- Token extracted from `?token=` URL param via `queryValue("token")` — returns raw string
- Sent as `Authorization: Bearer ${rawToken}` to `api/v1/jwt/portal` — no transformation
- Variable is named `rawToken`, emphasizing it is used as-is
- Never parsed, decoded, or inspected — only truthiness check (`if (bearerToken)`)
- After exchange for a Portal JWT, the original token is never used again
- Test mocks use simple strings like `"goodStudentToken"` — confirming no format assumptions

**collaborative-learning** (repo: `concord-consortium/collaborative-learning`)
- Token extracted from `?token=` URL param via `queryValue("token")` — returns raw string
- Stored as `this.bearerToken` (plain `string` property on the `Portal` class)
- Sent as `Authorization: Bearer ${bearerToken}` to `api/v1/jwt/portal`
- Never parsed, decoded, or inspected
- After exchange, the token is removed from the URL via `convertURLToOAuth2()` and replaced with OAuth2 parameters
- Test mocks use simple strings like `"goodStudentToken"` — confirming no format assumptions

**geniventure** (repo: `concord-consortium/geniblocks`)
- Token extracted from `?token=` URL param via generic query string parser into `urlParams.token`
- Sent as `Authorization: Bearer ${urlParams.token}` to `api/v1/jwt/firebase`
- Never parsed, decoded, or inspected
- After exchange, the token is stripped from the URL via `updateUrlParameter("token")`
- The `jwt.decode()` call in the codebase is applied to the Firebase JWT **response**, not the input bearer token

#### Conclusion

**Option B (replacing client-less grants with JWTs) is viable.** All three active runtimes treat the bearer token as an opaque string. They extract it from the URL, send it verbatim in an `Authorization: Bearer` header, and never inspect its format. Changing the token from an AccessGrant token to a short-lived JWT would not require any changes to these runtimes.

### Remaining Work

1. **Test locally** by launching from a local Portal with a JWT token instead of an AccessGrant token, to verify the end-to-end flow works.

