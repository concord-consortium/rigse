# OAuth2 Launch Parameter Research

**Date:** 2026-03-06
**Status:** Complete
**Related:** `../portal-authentication-unification-design.md` Section 9 Next Steps, Step 3

---

## Purpose

Step 3 of the auth unification design calls for adding OAuth2 launch support to ExternalActivities. Before designing the standard parameter set, we need to understand:

1. What URL parameters do clients that already support OAuth2 implicit launch expect?
2. What URL parameters does the Portal currently add when launching assignments and reports?

This research inventories both sides so the design can align on a standard set of parameters.

### Prior research

The "SPA OAuth2 initialization pattern" section of `docs/external-services.md` already documents the naming difference between clients (`auth-domain` vs `authDomain`) and the shared OAuth2 implicit grant flow. It also notes that portal-report and Activity Player derive the resource link from the `offering` URL parameter rather than having a dedicated `resourceLinkId` parameter (only CLUE has that). This document expands on that prior research with a full parameter inventory for each client and each portal launch path.

---

## Method

1. **Portal-side parameter review:** Read the Portal source code for all launch paths (`external_activity.rb`, `offerings_controller.rb`, `create_collaboration.rb`, `external_report.rb`)
2. **Client-side parameter review:** Searched each client repository in the `concord-consortium` GitHub org using `gh search code` and `gh api` to read source files, focusing on OAuth2 initialization, URL parameter parsing, and auth utility modules

---

## 1. Portal-Side Launch Parameters

### 1.1 Non-LARA ExternalActivity Launch (student assignment)

**Source:** `external_activity.rb:142-158`

The Portal takes the ExternalActivity's `url` and appends parameters based on the activity's configuration flags:

| Parameter | Condition | Value | Example |
|---|---|---|---|
| `learner` | `append_learner_id_to_url` | `learner.id` | `learner=12345` |
| `c` | `append_survey_monkey_uid` | `learner.user.id` | `c=678` |
| `token` | `append_auth_token` | Short-lived Portal JWT (180s) with `learner_id` and `user_type` claims | `token=eyJ...` |
| `domain` | `append_auth_token` | Portal root URL | `domain=https://learn.concord.org/` |
| `domain_uid` | `append_auth_token` | `learner.user.id` | `domain_uid=678` |

Additionally, the `offerings_controller.rb` may append `showFeedback=true` if `params[:show_feedback]` is present.

### 1.2 LARA ExternalActivity Launch (student assignment)

**Source:** `offerings_controller.rb:52-70`

For activities whose Tool has `source_type == 'LARA'`, the Portal replaces the entire query string:

| Parameter | Value | Purpose |
|---|---|---|
| `externalId` | `learner.id` | Learner record ID |
| `returnUrl` | `learner.remote_endpoint_url` | Endpoint for saving student work |
| `logging` | boolean | Whether logging is enabled for class or activity |
| `domain` | Portal root URL | Portal base URL for LARA auth |
| `domain_uid` | `current_visitor.id` | User ID at the portal |
| `class_info_url` | `offering.clazz.class_info_url(...)` | Full API URL for class info |
| `context_id` | `offering.clazz.class_hash` | Class hash (LTI-compatible) |
| `platform_id` | `APP_CONFIG[:site_url]` | Portal site URL (LTI-compatible) |
| `platform_user_id` | `current_visitor.id` | User ID (LTI-compatible) |
| `resource_link_id` | `offering.id` | Offering ID (LTI-compatible) |

### 1.3 Collaboration Launch

**Source:** `create_collaboration.rb:66-86`

When a collaboration is created, the Portal builds a URL for the external activity with these parameters:

| Parameter | Value | Purpose |
|---|---|---|
| `domain` | Portal root URL | Portal base URL |
| `domain_uid` | `owner_learner.user.id` | Owner's user ID |
| `collaborators_data_url` | API URL for collaboration data | Endpoint to fetch collaborator info |
| `logging` | boolean | Whether logging is enabled |
| `token` | Short-lived Portal JWT (180s) | Only if `append_auth_token` is true |

### 1.4 Offering Report Launch (teacher)

**Source:** `external_report.rb:49-63`

| Parameter | Value | Purpose |
|---|---|---|
| `reportType` | `'offering'` | Report type identifier |
| `offering` | Full API URL for offering | e.g., `https://learn.concord.org/api/v1/offerings/123` |
| `classOfferings` | Full API URL for class offerings | e.g., `https://learn.concord.org/api/v1/offerings?class_id=456` |
| `class` | Full API URL for class | e.g., `https://learn.concord.org/api/v1/classes/456` |
| `token` | AccessGrant token (2-hour) | Client-backed OAuth token |
| `username` | `user.login` | User's login name |
| `logging` | `'true'` | Only if logging enabled on offering or class |
| `studentId` | `user.id` | Only for student reports (when `allowed_for_students`) |
| `researcher` | `'true'` | Only when launched from researcher context |

### 1.5 Class Report Launch (teacher)

**Source:** `external_report.rb:66-81`

| Parameter | Value | Purpose |
|---|---|---|
| `reportType` | `'class'` | Report type identifier |
| `class` | Full API URL for class | e.g., `https://learn.concord.org/api/v1/classes/456` |
| `classOfferings` | Full API URL for class offerings | e.g., `https://learn.concord.org/api/v1/offerings?class_id=456` |
| `token` | AccessGrant token (2-hour) | Client-backed OAuth token |
| `username` | `user.login` | User's login name |
| `logging` | `'true'` | Only if logging enabled on class |
| `researcher` | `'true'` | Only when launched from researcher context |

---

## 2. Client-Side OAuth2 Initialization Parameters

### 2.1 CLUE (collaborative-learning)

**Repo:** `concord-consortium/collaborative-learning`
**OAuth Client ID:** `"clue"` (hardcoded)
**OAuth2 Support:** Yes

#### Parameters consumed at startup

**Authentication parameters:**

| Parameter | Name Convention | Purpose |
|---|---|---|
| `token` | — | Short-lived bearer token from portal launch |
| `authDomain` | camelCase | Portal URL for OAuth2 authorization (triggers OAuth2 flow) |
| `resourceLinkId` | camelCase | Offering ID, passed to portal when requesting JWTs |
| `domain` | — | Portal domain (older parameter, from launch URL) |
| `domain_uid` | snake_case | User ID at the portal domain |

**Report/teacher parameters:**

| Parameter | Name Convention | Purpose |
|---|---|---|
| `class` | — | Class info API URL |
| `offering` | — | Offering info API URL |
| `reportType` | camelCase | Report type (e.g., `"offering"`) |
| `classOfferings` | camelCase | Class offerings API URL |
| `researcher` | — | `"true"` for researcher mode |
| `targetUserId` | camelCase | User ID to target as researcher |

**Content parameters:**

| Parameter | Purpose |
|---|---|
| `unit` | Unit code (e.g., `"sas"`, `"msa"`) |
| `problem` | Problem ordinal (e.g., `"2.1"`) |

#### OAuth2 flow

1. If `authDomain` is present and no `access_token` in hash: saves URL params to `sessionStorage`, redirects to `{authDomain}/auth/oauth_authorize` with `client_id=clue`, `redirect_uri`, `response_type=token`, `state`
2. Portal redirects back with `#access_token=...&state=...`
3. CLUE restores saved params from `sessionStorage`, extracts access token

#### `convertURLToOAuth2()` function

After initial token-based launch, CLUE rewrites the URL for reload support:
- **Removes:** `token`
- **Adds:** `authDomain` (portal base URL), `resourceLinkId` (offering ID)
- **Preserves:** all other parameters (`domain`, `domain_uid`, `unit`, `problem`, etc.)

This means after the first launch, reloading the page triggers OAuth2 instead of trying to reuse the expired launch token.

#### JWT requests

- Portal JWT: `GET {domain}/api/v1/jwt/portal?resource_link_id={resourceLinkId}`
- Firebase JWT: `GET {domain}/api/v1/jwt/firebase?firebase_app=collaborative-learning&class_hash={hash}&resource_link_id={id}&target_user_id={id}`

---

### 2.2 Activity Player

**Repo:** `concord-consortium/activity-player`
**OAuth Client ID:** `"activity-player"` (hardcoded)
**OAuth2 Support:** Yes

#### Parameters consumed at startup

**Authentication parameters:**

| Parameter | Name Convention | Purpose |
|---|---|---|
| `token` | — | Short-lived bearer token from portal launch |
| `auth-domain` | **kebab-case** | Portal URL for OAuth2 authorization |
| `domain` | — | Portal base URL (fallback to `auth-domain`) |
| `domain_uid` | snake_case | User ID at the portal domain |
| `firebaseApp` | camelCase | Firebase app name override |

**Content parameters:**

| Parameter | Purpose |
|---|---|
| `activity` | Activity to load (sample ID or JSON URL) |
| `sequence` | Sequence to load (sample ID or JSON URL) |
| `sequenceActivity` | Which activity in sequence |
| `page` | Specific page to show |
| `collaborators_data_url` | Collaborators data endpoint |
| `answersSourceKey` | Firestore collection for answers |
| `showFeedback` | Show feedback page |

**UI parameters:**

| Parameter | Purpose |
|---|---|
| `mode` | UI mode (e.g., `"teacher-edition"`) |
| `preview` | Teacher preview mode |

#### OAuth2 flow

Same pattern as CLUE:
1. If `auth-domain` is present and no `token`: saves URL params to `sessionStorage`, redirects to `{auth-domain}/auth/oauth_authorize` with `client_id=activity-player`
2. Portal redirects back with `#access_token=...&state=...`
3. Restores params, extracts token

**Note:** Activity Player's OAuth2 support is **not used for portal-launched student assignments**. Those launches use a JWT `token` parameter (see flow below). OAuth2 is used for non-assignment scenarios that need an authenticated user but not an offering context — e.g., teacher edition preview (`?mode=teacher-edition`), standalone activity viewing, or other cases where the user navigates directly to Activity Player with an `auth-domain` parameter. In these cases the resulting Portal JWT has `user_type: "user"` with no `offering_id`.

#### Token priority

```javascript
return queryValue("token") || accessToken;
```
Direct `token` parameter takes priority over OAuth2 access token.

#### Portal-launched assignment flow (step by step)

Activity Player activities have `source_type = "Activity Player"` (not `"LARA"`), so they take the **non-LARA** code path in `offerings_controller.rb:73`:

1. **Portal builds launch URL:** calls `@offering.runnable.url(learner, root_url)` ([external_activity.rb:142](rails/app/models/external_activity.rb#L142))
2. **`url()` method appends params** based on the activity's config flags. Activity Player activities have `append_auth_token = true` (set during LARA→AP migration in `lara2.rake:51`), so:
   - Appends `token=<JWT>` — a short-lived (180s) Portal JWT containing `{learner_id: <id>, user_type: "learner"}` plus the standard `uid`, `iss`, `iat`, `exp` claims
   - Appends `domain=<portal_root_url>&domain_uid=<user_id>`
3. **Browser redirects** to something like: `https://activity-player.concord.org/?activity=https://...&token=eyJ...&domain=https://learn.concord.org/&domain_uid=123`
4. **Activity Player reads `token` from URL** — uses it as a Bearer token for Portal API calls
5. **Activity Player requests Portal JWT:** `GET {domain}/api/v1/jwt/portal` with `Authorization: Bearer/JWT {token}`
6. **Portal's `jwt_controller#portal`** calls `handle_initial_auth` → `check_for_auth_token`:
   - Decodes the launch JWT → finds `uid`, `learner_id`, `user_type: "learner"`
   - Returns `[user, {learner: <Portal::Learner>}]`
7. **Portal mints a new Portal JWT** with full learner claims: `domain`, `user_type: "learner"`, `user_id`, `learner_id`, `class_info_url`, `offering_id` ([jwt_controller.rb:189-198](rails/app/controllers/api/v1/jwt_controller.rb#L189-L198))
8. **Activity Player receives JWT** with `offering_id` and `class_info_url` in the claims — this is how it knows which offering it's running

**Key insight:** The launch JWT (`token` URL param) contains only `learner_id` and `user_type`. But because `learner_id` maps to a specific learner record (which belongs to an offering), the Portal can derive the full offering context when minting the subsequent Portal JWT. The offering ID is **not** in the launch URL — it's derived server-side from the learner.

**Important:** This flow works because the launch JWT embeds a `learner_id`. If the launch token were replaced with an AccessGrant token or an OAuth2 access token (neither of which carry a `learner_id`), the Portal JWT endpoint would have no way to determine the offering context — it would fall into the generic "user" branch ([jwt_controller.rb:206-216](rails/app/controllers/api/v1/jwt_controller.rb#L206-L216)) and the returned JWT would lack `offering_id` and `class_info_url`. Activity Player would then not know which offering it's running.

#### Resource link handling

Activity Player does **not** have a `resourceLinkId` URL parameter. It relies entirely on the chain above: launch JWT → `learner_id` → Portal derives offering → Portal JWT includes `offering_id`.

For an OAuth2 launch (where the token is an AccessGrant with no `learner_id`), Activity Player would need either:
- (a) A new `resource_link_id` URL parameter to pass when requesting a Portal JWT (same approach CLUE uses), or
- (b) The Portal to associate the offering context with the AccessGrant before launch

#### JWT requests

- Portal JWT: `GET {domain}/api/v1/jwt/portal` with Bearer token (no `resource_link_id` param — offering context derived from `learner_id` in the launch JWT)
- Firebase JWT: `GET {domain}/api/v1/jwt/firebase?firebase_app={app}`

**Note:** Activity Player does NOT strip the `token` from the URL after extracting it (unlike CLUE and geniventure). It also does NOT have a `convertURLToOAuth2()` equivalent.

---

### 2.3 portal-report

**Repo:** `concord-consortium/portal-report`
**OAuth Client ID:** `"portal-report"` (hardcoded)
**OAuth2 Support:** Yes

#### Parameters consumed at startup

**Authentication parameters:**

| Parameter | Name Convention | Purpose |
|---|---|---|
| `token` | — | AccessGrant bearer token from portal report launch |
| `auth-domain` | **kebab-case** | Portal URL for OAuth2 authorization |

**Context parameters (from portal report launch):**

| Parameter | Name Convention | Purpose |
|---|---|---|
| `class` | — | Class info API URL |
| `offering` | — | Offering info API URL |
| `reportType` | camelCase | Report type (`"offering"` or `"class"`) |
| `studentId` | camelCase | User ID of student (for student reports) |
| `username` | — | User's login name |
| `logging` | — | Whether logging is enabled |
| `researcher` | — | `"true"` for researcher mode |

**Data source parameters:**

| Parameter | Purpose |
|---|---|
| `sourceKey` | Firestore source key for activity structure |
| `answersSourceKey` | Firestore source key for answers |
| `firebase-app` | Firebase app name (default: `"report-service"`) |

**View parameters:**

| Parameter | Purpose |
|---|---|
| `dashboard` | Show dashboard view |
| `portal-dashboard` | Show new portal dashboard view |
| `activityIndex` | Show specific activity in sequence |
| `iframeQuestionId` | Show specific iframe question full-size |

#### OAuth2 flow

Same sessionStorage pattern:
1. If `auth-domain` present and no access token: saves URL params, redirects to `{auth-domain}/auth/oauth_authorize` with `client_id=portal-report`
2. Portal redirects back with `#access_token=...&state=...`
3. Restores params, extracts token

#### Token usage

Unlike CLUE and Activity Player, portal-report does **not** exchange its token for a Portal JWT. It uses the AccessGrant token (or OAuth2 access token) directly as a Bearer token for all Portal API calls.

It does request a Firebase JWT: `GET {portalBase}/api/v1/jwt/firebase?firebase_app={app}&class_hash={hash}&resource_link_id={id}&target_user_id={userId}&researcher=true`

#### Resource link handling

portal-report receives offering context as a full API URL in the `offering` parameter (e.g., `https://learn.concord.org/api/v1/offerings/123`). It fetches this URL using its Bearer token and extracts the offering ID from the **API response's `id` field** (`offeringData.id.toString()`). This offering ID is then passed as `resource_link_id` when requesting Firebase JWTs. Similarly, `class_hash` comes from the class API response (`classData.class_hash`).

This means portal-report's OAuth2 flow does not have the "offering context" problem that Activity Player has — the context is always explicit in the URL parameters, and the token is purely for authentication. The OAuth2 researcher link pattern (`?auth-domain=...&offering=...&class=...&reportType=...&researcher=true`) works because all context is in the URL.

---

### 2.4 Geniventure (geniblocks)

**Repo:** `concord-consortium/geniblocks`
**OAuth2 Support:** No

#### Parameters consumed at startup

| Parameter | Purpose |
|---|---|
| `domain` | Portal domain URL |
| `token` | Bearer token for portal API calls |
| `domain_uid` | User ID at the portal |
| `class_info_url` | Class info URL |
| `externalId` | External learner ID |
| `returnUrl` | URL for saving student work |

Geniventure only supports token-based launch. It does not have any OAuth2 client code, does not recognize `authDomain` or `auth-domain` parameters, and has no `convertURLToOAuth2()` equivalent.

After extracting the token, it requests a Firebase JWT (`GET {domain}api/v1/jwt/firebase?firebase_app={projectId}`) and then strips the `token` from the URL.

---

### 2.5 Other OAuth2 Clients (not portal-launched)

The following clients use OAuth2 implicit grant with the Portal but are **not launched from the Portal** as assignments or reports. They are standalone tools where the user navigates directly to the app, which then initiates OAuth2 to authenticate. They are included here for pattern comparison.

#### glossary-plugin

**Repo:** `concord-consortium/glossary-plugin`
**OAuth Client ID:** `"glossary-plugin"` (hardcoded)
**Auth domain parameter:** `portal` (query param, e.g., `?portal=https://learn.concord.org`)

The authoring flow uses `?portal=` to know which Portal to authenticate with, then redirects to `{portal}/auth/oauth_authorize`. Hash parameters (e.g., `#glossaryId=`) are preserved via the OAuth `state` parameter since `redirect_uri` cannot include fragments. After auth, it requests a Firebase JWT via `GET {portal}/api/v1/jwt/firebase?firebase_app=glossary-plugin`.

The dashboard flow receives `?class=`, `?offering=`, and `?token=` parameters (same pattern as portal-report).

#### vortex

**Repo:** `concord-consortium/vortex`
**OAuth Client ID:** `"vortex"` (hardcoded)
**Auth domain parameter:** `portalUrl` (query param, or derived from hostname)

Used for authoring experiments. The authoring app uses `?portalUrl=` to specify the Portal, then redirects to `{portalUrl}/auth/oauth_authorize`. After auth, it requests a Firebase JWT via `GET {portalUrl}/api/v1/jwt/firebase?firebase_app=token-service`, then uses the Token Service for S3 resource management.

#### report-service (researcher-reports SPA)

**Repo:** `concord-consortium/report-service`
**OAuth Client ID:** `"research-report-server"` (configurable)
**Auth domain parameter:** Configured in app, not a URL parameter

The researcher-reports SPA frontend uses `client-oauth2` with the implicit grant flow. The Elixir backend also has an OAuth2 integration using authorization code flow, but the frontend SPA uses implicit grant for browser-based access.

#### token-service (example app)

**Repo:** `concord-consortium/token-service`
**OAuth Client ID:** `"token-service-example-app"` (configurable via UI)
**Auth domain parameter:** Configured via UI input

A developer example app demonstrating OAuth2 integration with the Portal. Uses configurable Portal URL and OAuth client name via a form UI, then follows the standard implicit grant redirect to `/auth/oauth_authorize`.

#### aws-learner-logs (server-side, authorization code flow)

**Repo:** `concord-consortium/aws-learner-logs`
**OAuth Client ID:** Configured via environment variable (`PORTAL_AUTH_CLIENT_ID`)
**Grant type:** Authorization code (confidential client, not implicit)

This is a **server-side** app that uses the authorization code grant flow (not implicit). It redirects to `{PORTAL_ROOT_URL}auth/concord_id/authorize?response_type=code`, receives a code callback, and exchanges it for an access token server-to-server using `client_secret`. Included for completeness but uses a different OAuth2 endpoint path (`auth/concord_id/authorize` vs `auth/oauth_authorize`).

---

## 3. Summary: OAuth2 Initialization Parameter Comparison

### Prior team decision: camelCase for URL parameters

The team decided years ago to use **camelCase** for URL parameter names when there is a choice. The rationale:

1. **Consistency with JavaScript.** Our client code is mostly JavaScript/TypeScript, which uses camelCase for variable names. Using camelCase for URL parameters means a parameter key can be used directly as a JS property name without transformation.
2. **kebab-case is ruled out.** A kebab-case parameter like `auth-domain` cannot be used as a JS property name (`params.auth-domain` is a syntax error — the `-` is interpreted as subtraction). It must be accessed with bracket notation (`params["auth-domain"]`) or renamed on import.
3. **snake_case is less conventional in JS.** While it works syntactically (`params.auth_domain`), it doesn't match JS naming conventions and requires mental translation.

This prior decision means **CLUE's naming (`authDomain`, `resourceLinkId`) follows the team convention**, while Activity Player and portal-report's `auth-domain` (kebab-case) diverges from it. The Portal's server-side LTI-borrowed names (`resource_link_id`, `context_id`) use snake_case, which is natural for Ruby but doesn't match the client-side convention.

**Why not adopt LTI's snake_case instead?** LTI 1.3 moved away from flat snake_case parameter names to URI-namespaced JWT claims (see Section 4.1). The flat snake_case names like `resource_link_id` were an LTI 1.1 convention that LTI itself has superseded. Since we're not implementing the LTI 1.3 protocol (it requires a server component incompatible with our SPAs), there's no ongoing alignment benefit from keeping snake_case for client-facing parameters.

**Migration will be incremental.** The codebase already has a mix of conventions — report launches use camelCase (`reportType`, `classOfferings`, `studentId`), LARA launches use snake_case (`resource_link_id`, `context_id`, `domain_uid`), and Activity Player/portal-report use kebab-case (`auth-domain`). Committing to camelCase for new and updated parameters doesn't make the situation worse; it establishes a clear direction. The most persistent legacy snake_case parameters will be `domain_uid` and `collaborators_data_url`, but these can be migrated as clients are updated, and some (like `domain_uid`) may be eliminated entirely by OAuth2 launch.

### Auth domain parameter naming across all implicit-grant clients

| Client | Parameter name | Convention |
|---|---|---|
| CLUE | `authDomain` | camelCase |
| Activity Player | `auth-domain` | kebab-case |
| portal-report | `auth-domain` | kebab-case |
| glossary-plugin | `portal` | single-word |
| vortex | `portalUrl` | camelCase |
| report-service (researcher-reports) | configured in app | — |
| token-service (example) | configured via UI | — |

The portal-launched clients (CLUE, Activity Player, portal-report) use `authDomain` or `auth-domain`. The standalone clients (glossary-plugin, vortex) use different names (`portal`, `portalUrl`). All use the same underlying OAuth2 implicit grant flow and Portal endpoint (`/auth/oauth_authorize`).

### Authentication trigger parameters (portal-launched clients)

| Parameter | CLUE | Activity Player | portal-report | Geniventure |
|---|---|---|---|---|
| `authDomain` (camelCase) | Yes | — | — | — |
| `auth-domain` (kebab-case) | — | Yes | Yes | — |
| `token` | Yes (launch) | Yes (launch) | Yes (launch) | Yes (launch) |

### Resource link parameters

| Parameter | CLUE | Activity Player | portal-report | Geniventure |
|---|---|---|---|---|
| `resourceLinkId` (camelCase) | Yes (explicit param) | — | — | — |
| `offering` (full API URL) | Yes (report mode) | — | Yes (from portal launch) | — |
| Derived from JWT claims | — | Yes (`offering_id` claim) | — | — |

As noted in `docs/external-services.md`, only CLUE has a dedicated `resourceLinkId` parameter. portal-report derives the offering context from the `offering` URL parameter (a full API URL like `https://learn.concord.org/api/v1/offerings/123`). Activity Player derives it entirely from the Portal JWT claims after exchanging its bearer token.

**Key naming difference:** CLUE uses camelCase (`authDomain`, `resourceLinkId`), while Activity Player and portal-report use kebab-case (`auth-domain`). All three use the same underlying OAuth2 implicit grant flow with the same sessionStorage-based parameter preservation pattern.

### Context parameters that would be needed for OAuth2 launch

For the Portal to launch an assignment via OAuth2 instead of a token, it needs to provide enough context for the client to:
1. Know which portal to authenticate with (auth domain)
2. Know which offering/class it's working with (resource link / context)
3. Access any content-specific parameters (unit, problem, activity URL, etc.)

**Minimum parameters for OAuth2 assignment launch:**

| Parameter | Purpose | Currently provided by |
|---|---|---|
| Auth domain | Portal URL for OAuth2 | Not provided (would be new) |
| Resource link ID / offering | Which assignment | LARA launch only (`resource_link_id`); non-LARA launches embed this in the JWT |
| Class context | Which class | LARA launch only (`context_id`, `class_info_url`); non-LARA launches embed this in the JWT |

**Parameters that would no longer be needed:**

| Parameter | Why not needed |
|---|---|
| `token` | Replaced by OAuth2 flow |
| `domain` | Replaced by auth domain (same value but different semantic) |
| `domain_uid` | User identity comes from OAuth2 authentication |

**Parameters that would still be needed:**

| Parameter | Why still needed |
|---|---|
| `collaborators_data_url` | Collaboration-specific; not derivable from offering |
| `logging` | Per-class/per-activity flag |
| Content params (`activity`, `unit`, `problem`, etc.) | Already in the ExternalActivity URL, not added by Portal |

### Client OAuth2 client IDs

| Client | OAuth Client ID | Grant type | Launched from Portal? |
|---|---|---|---|
| CLUE | `"clue"` | Implicit | Yes (assignment + report) |
| Activity Player | `"activity-player"` | Implicit | Yes (assignment) |
| portal-report | `"portal-report"` | Implicit | Yes (report) |
| glossary-plugin | `"glossary-plugin"` | Implicit | No (standalone + LARA plugin) |
| vortex | `"vortex"` | Implicit | No (standalone authoring) |
| report-service | `"research-report-server"` | Implicit | No (standalone researcher reports) |
| token-service (example) | `"token-service-example-app"` | Implicit | No (dev example) |
| aws-learner-logs | env var configured | Authorization code | No (server-side) |
| Geniventure | — | — | Yes (assignment, no OAuth2) |

### Client `convertURLToOAuth2()` support

| Client | Has conversion? | What it does |
|---|---|---|
| CLUE | Yes | Removes `token`, adds `authDomain` + `resourceLinkId` |
| Activity Player | No | Does not convert; `token` stays in URL |
| portal-report | No | Does not convert; uses `token` or `auth-domain` as provided |
| Geniventure | No | No OAuth2 support |

---

## 4. LTI 1.3 Naming Conventions

The Portal already borrows several parameter names from the LTI specification (`resource_link_id`, `context_id`, `platform_id`, `platform_user_id`). Understanding the full LTI 1.3 naming conventions helps inform what a standard parameter set should look like.

**Important caveat:** LTI 1.3 does not support client-side-only (implicit grant) launching. It uses an OIDC third-party initiated login flow where the tool must have a **server** that verifies JWT signatures using the platform's public key. This makes LTI 1.3 incompatible with pure SPA clients that have no backend. Our OAuth2 implicit grant approach exists precisely because our SPA clients (CLUE, Activity Player, portal-report) have no server component that could participate in LTI 1.3. We are not adopting LTI 1.3 as a protocol — we are only looking at its **naming conventions** for guidance on our own parameter design.

### 4.1 How LTI passes parameters

LTI 1.1 passed all parameters as **flat POST form fields** using `snake_case` names (e.g., `resource_link_id`, `context_id`, `launch_presentation_return_url`).

LTI 1.3 moved to **signed JWT claims** delivered via a form POST of an `id_token`. Parameters are no longer flat — they are organized into namespaced claim objects:

| LTI 1.1 POST parameter | LTI 1.3 JWT claim |
|---|---|
| `resource_link_id` | `https://purl.imsglobal.org/spec/lti/claim/resource_link` → `.id` |
| `context_id` | `https://purl.imsglobal.org/spec/lti/claim/context` → `.id` |
| `context_title` | `https://purl.imsglobal.org/spec/lti/claim/context` → `.title` |
| `context_label` | `https://purl.imsglobal.org/spec/lti/claim/context` → `.label` |
| `tool_consumer_instance_guid` | `https://purl.imsglobal.org/spec/lti/claim/tool_platform` → `.guid` |
| `user_id` | `sub` (OpenID Connect standard) |
| `lis_person_name_given` | `given_name` (OpenID Connect standard) |
| `lis_person_name_family` | `family_name` (OpenID Connect standard) |
| `roles` | `https://purl.imsglobal.org/spec/lti/claim/roles` (array of URIs) |
| `launch_presentation_return_url` | `https://purl.imsglobal.org/spec/lti/claim/launch_presentation` → `.return_url` |
| `custom_*` | `https://purl.imsglobal.org/spec/lti/claim/custom` → `.{key}` |

### 4.2 LTI 1.3 claim structure and naming convention

LTI 1.3 claims use **URI-namespaced keys** at the top level and **snake_case** for inner properties. The key claims are:

**Required claims:**

| Claim | Inner properties | Purpose |
|---|---|---|
| `message_type` | — (string) | e.g., `"LtiResourceLinkRequest"` |
| `version` | — (string) | `"1.3.0"` |
| `deployment_id` | — (string) | Identifies the platform-tool integration |
| `target_link_uri` | — (string) | Tool endpoint URL |
| `resource_link` | `id` (required), `title`, `description` | The specific assignment/placement |
| `sub` | — (string) | User ID (OIDC standard) |
| `roles` | — (array of URIs) | User roles in context |

**Optional claims:**

| Claim | Inner properties | Purpose |
|---|---|---|
| `context` | `id` (required), `label`, `title`, `type` | Course/class context |
| `tool_platform` | `guid` (required), `name`, `url`, `contact_email`, `description`, `product_family_code`, `version` | Platform identification |
| `launch_presentation` | `document_target`, `return_url`, `height`, `width`, `locale` | UI presentation hints |
| `custom` | arbitrary key-value pairs (string values) | Custom parameters |
| `lis` | `person_sourcedid`, `course_offering_sourcedid`, `course_section_sourcedid` | SIS integration data |

Inner property names consistently use **snake_case**: `return_url`, `document_target`, `product_family_code`, `contact_email`, `person_sourcedid`, `course_offering_sourcedid`.

### 4.3 How the Portal already uses LTI names

The Portal's LARA launch path (Section 1.2) adopted several LTI-inspired parameter names as **flat URL query parameters**:

| Portal parameter | LTI origin | Notes |
|---|---|---|
| `resource_link_id` | `resource_link` → `.id` | Portal uses the LTI 1.1 flat name |
| `context_id` | `context` → `.id` | Portal uses the LTI 1.1 flat name |
| `platform_id` | `tool_platform` → `.guid` | Different name; LTI uses `guid` |
| `platform_user_id` | `sub` | Different name; LTI uses `sub` |

The Portal uses the **LTI 1.1 flat snake_case style** (`resource_link_id`, `context_id`) rather than the LTI 1.3 nested claim style. This is natural since these are URL query parameters, not JWT claims.

### 4.4 Implications for OAuth2 launch parameter design

1. **snake_case is the LTI convention.** Both LTI 1.1 (flat parameters) and LTI 1.3 (inner properties) use snake_case. The Portal's existing LTI-borrowed names (`resource_link_id`, `context_id`, `platform_id`, `platform_user_id`) follow this convention.

2. **Our clients don't follow this convention.** CLUE uses camelCase (`resourceLinkId`, `authDomain`), Activity Player and portal-report use kebab-case (`auth-domain`). Neither matches the LTI snake_case convention.

3. **LTI 1.3 groups related data into claim objects.** Rather than flat parameters like `context_id` + `context_title` + `context_label`, LTI 1.3 nests them under a single `context` claim. This grouping pattern doesn't translate directly to URL query parameters, but it shows the spec's preference for structured data.

4. **LTI names are well-established vocabulary.** Using `resource_link_id` rather than `offeringId` or `resourceLinkId` aligns with an industry standard that developers may already know. The Portal already chose these names for LARA launches.

5. **The `platform_id` naming diverges from LTI.** LTI uses `tool_platform.guid` for the platform identifier and `iss` (issuer) for the platform's base URL. The Portal's `platform_id` maps to the `iss` claim value (a URL), not the `guid`. This is a minor divergence but worth noting.

---

## 5. Observations for Step 3 Design

1. **Naming convention is decided: camelCase.** The team previously decided to use camelCase for URL parameters (see Section 3). CLUE already follows this (`authDomain`, `resourceLinkId`). Activity Player and portal-report's `auth-domain` (kebab-case) diverges from this decision and would need to be updated. The Portal's server-side LTI-borrowed names (`resource_link_id`) use snake_case, which is fine for Ruby code but the client-facing URL parameters should use camelCase equivalents (e.g., `resourceLinkId`).

2. **CLUE's `convertURLToOAuth2()` already shows the target pattern.** After a token-based launch, CLUE rewrites the URL to `?authDomain={portal}&resourceLinkId={offeringId}&...`. This is essentially what an OAuth2 launch URL from the Portal would look like — just without the initial `token` parameter.

3. **Activity Player derives context from JWT claims.** Unlike CLUE (which uses `resourceLinkId` to request a JWT with offering context), Activity Player gets its offering/class context from the Portal JWT claims (`offering_id`, `class_info_url`). For OAuth2 launch, Activity Player would need a `resource_link_id` (or equivalent) parameter so it can pass it when requesting a JWT, since the OAuth2 access token carries no offering context.

4. **Report launches are different from assignment launches.** Reports receive full API URLs (`offering=https://...`, `class=https://...`) rather than IDs. They also receive the token from a client-backed AccessGrant rather than a short-lived JWT. Report OAuth2 launch migration is out of scope for Step 3 but the parameter research is included here for completeness.

5. **Geniventure needs a separate migration path.** It has no OAuth2 support. If it needs to be migrated, OAuth2 client code would need to be added. Given its simpler architecture (Firebase-only, no Firestore), the effort may not be justified if the app is nearing end-of-life. Production activity should be checked.

6. **The `logging` parameter is not derivable from the offering.** The Portal computes it from `offering.clazz.logging || offering.runnable.logging`. Clients would need this passed as a launch parameter or fetch it themselves via the offerings API (which already includes logging info in the response).

7. **`collaborators_data_url` is collaboration-specific.** This URL is only relevant for collaboration launches and would still need to be passed as a parameter. OAuth2 launch doesn't change this.

8. **LTI conventions favor snake_case, but our team convention is camelCase.** The Portal's existing LTI-borrowed names (`resource_link_id`, `context_id`) use snake_case, matching the LTI spec. However, the team's prior decision is to use camelCase for client-facing URL parameters (see Section 3). This means OAuth2 launch parameters should use camelCase (`resourceLinkId`, `contextId`) even though the Portal's internal Ruby code and LTI spec use snake_case equivalents. The JwtController already accepts `resource_link_id` as a query parameter — either the controller should accept both conventions, or clients should use the snake_case form only when calling Portal API endpoints.
