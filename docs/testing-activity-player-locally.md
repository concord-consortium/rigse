# Testing Activity Launches Locally (Without LARA)

**Date:** 2026-02-27
**Context:** Testing the portal's activity launch flow with the production Activity Player or CLUE, without setting up a local LARA instance. Useful for verifying changes to launch tokens, authentication, or the JWT exchange flow.

---

## Overview

Normally, an author creates an activity in LARA, publishes it to the portal, and students launch it in the Activity Player or CLUE. But for portal-side testing you can skip LARA entirely by creating an `ExternalActivity` record directly in the portal admin UI that points to the production runtime with a publicly accessible activity definition.

The portal uses the same launch code path for both Activity Player and CLUE — they are both non-LARA ExternalActivities that go through `external_activity.url(learner, domain)`. The differences are purely in configuration: the ExternalActivity URL, the Tool record, and the auth client / external report setup.

The end-to-end flow being tested:

1. Student clicks "Run" on an assignment in the portal
2. Portal generates a launch URL with `?token=<JWT>&domain=<portal_url>&domain_uid=<user_id>`
3. Browser redirects to the runtime (AP or CLUE) with those parameters
4. The runtime extracts the token and calls `GET <domain>/api/v1/jwt/portal` with `Authorization: Bearer <token>` to exchange it for a longer-lived portal JWT
5. The runtime calls `GET <domain>/api/v1/jwt/firebase?firebase_app=<name>` with the portal JWT to get a Firebase token
6. The runtime authenticates with Firebase and can read/write student data

Steps 1-3 test the portal's token generation. Steps 4-5 test token validation and JWT exchange. Step 6 tests the full Firebase integration.

## Prerequisites

- Portal running in GitHub Codespaces (these instructions assume Codespaces, but the approach works for any local setup with URL adjustments)

## Shared Setup Steps

These steps apply regardless of which runtime you're testing.

### 1. Set `JWT_HMAC_SECRET`

The portal needs an HMAC secret to sign and verify JWT launch tokens. Check your `.env` file:

```
JWT_HMAC_SECRET=XXXX
```

The placeholder `XXXX` will technically work for local testing (it's a valid string), but if you want something more realistic, use any string of 32+ characters. If you change this value, restart the container:

```bash
docker compose down && docker compose up -d
```

Verify it's set inside the container:

```bash
docker compose exec app bash -c 'echo $JWT_HMAC_SECRET'
```

### 2. Understand how the portal URL / `domain` parameter works

The runtime (AP or CLUE) runs in your browser and makes API calls back to the portal. The portal tells the runtime where to call back via the `domain` parameter in the launch URL.

**How `domain` is set:** The portal uses Rails' `root_url` helper, which is derived from the incoming HTTP request's `Host` header — **not** from `APP_CONFIG[:site_url]` or the `SITE_URL` environment variable. (`APP_CONFIG[:site_url]` from `config/settings.yml` is only used for `action_mailer.default_url_options` and a few non-controller contexts.) This means the `domain` will match whatever URL you use to access the portal in your browser.

**For Activity Player: use the public HTTPS codespace URL.** In the VS Code Ports tab, set port 3000's visibility to **Public**, then access the portal at:

```
https://<codespace-name>-3000.app.github.dev
```

This is recommended for Activity Player because:
- All requests between external SPAs (Activity Player, portal-report) and the portal stay HTTPS→HTTPS, avoiding mixed-content issues.
- The browser sends `Referer` headers on HTTPS→HTTPS requests. The Devise `bearer_token_authenticatable` strategy validates the `Referer` against the report client's `domain_matchers` — if the Referer is missing (as happens on HTTPS→HTTP downgrades), the strategy rejects the token and API calls return 403.

Using `http://127.0.0.1:3000` instead will work for the AP launch itself (it uses `check_for_auth_token`, which doesn't check Referer), but **portal-report will get 403 errors** because the browser won't send a Referer header on HTTPS→HTTP requests. Codespaces does not support HTTPS for locally forwarded ports.

**For CLUE: use `http://localhost:3000`.** CLUE's auth client has no `domain_matchers` configured, so the Referer validation issue doesn't apply — the CLUE dashboard works over HTTP. Using `localhost:3000` is also required because the CLUE staging firebase rules whitelist `localhost:3000` as a portal hostname (see step 8b). The codespace hostname is not in that whitelist, so using the public HTTPS URL would cause firebase writes to be rejected.

### 3. Create Tools

The portal needs Tool records for runtimes that use them. Check existing tools at:

```
http://127.0.0.1:3000/admin/tools
```

The Activity Player requires a Tool record. CLUE does not — it launches without one.

To create the Activity Player tool manually:

| Field | Value |
|-------|-------|
| Name | `ActivityPlayer` |
| Source Type | `ActivityPlayer` |
| Tool ID | `https://activity-player.concord.org` |

Or run the rake task (also creates a LARA tool):

```bash
docker compose exec app bundle exec rake app:setup:create_default_tools
```

#### Combined setup: `local_setup`

There is also a combined rake task that runs multiple shared setup steps at once:

```bash
docker compose exec app bundle exec rake app:setup:local_setup
```

This runs three sub-tasks:
1. `create_default_external_reports` — creates report service auth clients + external reports (for Activity Player)
2. `create_default_tools` — creates the LARA and ActivityPlayer Tool records
3. `sso:add_dev_client` — creates an SSO auth client for LARA (only needed if integrating with a local LARA instance)

Note: `local_setup` does **not** create Firebase apps or CLUE-specific auth clients / external reports — see the platform-specific sections below.

---

## Activity Player

Follow the shared setup steps above, then complete the steps below.

### 4a. Set up AP Firebase Apps

For the full end-to-end flow (student answers saved to Firebase), you need `FirebaseApp` records in the portal. The Activity Player will call the portal's `/api/v1/jwt/firebase` endpoint to get a Firebase token, and the portal needs the corresponding service account credentials to mint that token.

Go to the Firebase Apps admin page:

```
http://127.0.0.1:3000/admin/firebase_apps
```

**Required:** `report-service-dev` — used by the Activity Player to read/write student answers in Firestore. Credentials can be copied from `learn.staging.concord.org` under Admin > Firebase Apps.

**Optional:** `token-service` — used by some embedded interactives for collaborative data sharing via the Token Service. Not needed for basic Activity Player testing, but required if your activity includes interactives that use the Token Service. There is no rake task for this one; create it manually via the admin UI or Rails console if needed. Without it, you will see network errors for `firebase_app=token-service` requests in both the Activity Player and portal-report, but they do not prevent the apps from running.

#### Creating `report-service-dev`

**Rake task** (will prompt for the private key):

```bash
docker compose exec app bundle exec rake app:setup:add_report_service_firebase_app
```

### 5a. Set up AP External Reports (optional)

If you want teacher/student report buttons to appear on offerings, create the default external reports:

```bash
docker compose exec app bundle exec rake app:setup:create_default_external_reports
```

This creates auth clients and external reports for portal-report, including an "AP Report" configured with `answersSourceKey=activity-player.concord.org`.

**Note:** Without LARA, the activity structure will not be published to the report-service, so the report will not fully load. However, you can still validate that the report successfully makes API requests to the portal (check the Network tab for successful calls to `/api/v1/offerings`, `/api/v1/jwt/firebase`, etc.).

### 6a. Create an ExternalActivity for AP

Go to:

```
http://127.0.0.1:3000/eresources/new
```

Fill in the form:

| Field | Value |
|-------|-------|
| Name | Any descriptive name (e.g., "JWT Test Activity") |
| URL | An Activity Player URL with a real activity definition (see below) |
| Tool | ActivityPlayer |
| Append auth token | **checked** |
| Publication status | published |

#### Finding an activity URL

The `URL` field needs to point to the Activity Player with an `activity` (or `sequence`) parameter referencing a publicly accessible activity JSON. You can use a production activity from the Concord authoring system. The format is:

```
https://activity-player.concord.org/?activity=https://authoring.concord.org/api/v1/activities/<ID>.json
```

To find a valid activity ID, you can browse activities at `authoring.concord.org` or use one you already know. You can also find an activity in `learn.staging.portal.concord.org` and look at its portal settings to find the activity or sequence ID.

The activity JSON just needs to be publicly accessible — the Activity Player fetches it client-side.

### 7a. Assign and launch

Follow the steps in [Assign and launch the activity](#assign-and-launch-the-activity) below.

---

## CLUE

**Important**: CLUE launching from a local portal currently requires changing the access rules in the collaborative-learning-staging firebase project. Until that is fixed, this isn't a convenient setup. See step 8b (firebase rules) for more details.

Follow the shared setup steps above, then complete the steps below.

### 4b. Set up CLUE Auth Client

CLUE needs an auth client for authenticating API requests. Create one at:

```
http://127.0.0.1:3000/admin/clients
```

| Field | Value |
|-------|-------|
| Name | CLUE |
| App Id | clue |
| Client Type | public |
| Site Url | https://collaborative-learning.concord.org/ |
| Allowed Domains | <leave blank> |
| Allowed URL Redirects | https://collaborative-learning.concord.org/ |

### 5b. Set up CLUE Firebase App

CLUE requires its own Firebase app. Create it at:

```
http://127.0.0.1:3000/admin/firebase_apps
```

We are going to have CLUE use the staging firebase project. So we need to configure this firebase app differently than on staging or production.

| Field | Value |
|-------|-------|
| Name | collaborative-learning |
| Client Email | firebase-adminsdk-fbsvc@collaborative-learning-staging.iam.gserviceaccount.com |
| Private Key | <Copy from collaborative-learning-staging app on learn.portal.staging.concord.org> |

TODO: CLUE Should be updated so that it uses the portal's firebase app named `collaborative-learning-staging` when the firebaseEnv is set to staging. 

### 6b. Set up CLUE External Report (optional)

If you want teacher/student report or dashboard buttons to appear on CLUE offerings, create an external report at:

```
http://127.0.0.1:3000/admin/external_reports
```

| Field | Value |
|-------|-------|
| Name | CLUE Dashboard |
| Url | https://collaborative-learning.concord.org/?firebaseEnv=staging |
| Launch text | CLUE |
| Client | CLUE |
| Report Type | offering |
| Allowed For Students | false |

Note on learn.portal.staging.concord.org the client for the external report is `localhost`. This client has no allowed domains. This approach means the tokens for the external report are not validated against the domain. This makes it possible to load the CLUE report from any domain.

The real CLUE client is used though when the report tab is reloaded after its initial launch. This is because this reload goes through a OAuth flow to re authorize.

### 7b. Create an ExternalActivity for CLUE

Go to:

```
http://127.0.0.1:3000/eresources/new
```

Fill in the form:

| Field | Value |
|-------|-------|
| Name | Any descriptive name (e.g., "CLUE Test Activity") |
| URL | A CLUE URL (see below) |
| Tool | (none) |
| Append auth token | **checked** |
| Publication status | published |

#### Finding a CLUE URL

The `URL` field needs to point to CLUE with `unit` and `problem` parameters. Both are required. The firebaseEnv should be set to staging so you don't put your local data in the production firebase project. The format is:

```
https://collaborative-learning.concord.org/branch/master/?unit=<unit>&problem=<problem>&firebaseEnv=staging
```

For example: `https://collaborative-learning.concord.org/branch/master/?unit=msa&problem=1.4&firebaseEnv=staging`

### 8b. Update staging firebase rules

The CLUE firestore rules only match specific portals. The portal hostname is escaped by the CLUE client and that escaped hostname has to match one of the ones in the firebase rules. Currently this list is:
- localhost:3000
- learn_concord_org
- learn_staging_concord_org
- learn_portal_staging_concord_org
- learn-migrate_concord_org

However the `localhost:3000` entry was added manually to these staging rules. If someone redeploys the rules from the official set in the CLUE repo this entry will go away. 

### 9b. Assign and launch

Follow the steps in [Assign and launch the activity](#assign-and-launch-the-activity) below.

---

## Assign and launch the activity

### Create test user accounts

The portal seeds create default users (login / password is `password` for all):

| Login | Role |
|-------|------|
| `admin` | Site admin |
| `teacher` | Teacher (Valerie Frizzle) |

As the teacher (do all of this in one session to avoid extra login cycles):

1. Log in as `teacher` / `password`
2. Create a class if one doesn't exist
3. Note the class word (students use this to register)
4. Find your ExternalActivity (search for it or browse to it)
5. Click "Assign" and select the class

Then register a student:

1. Log out
2. Sign up as a new student
3. Join the teacher's class using the class word

### Launch as a student

1. Log in as the student
2. Navigate to the class
3. Click "Run" on the assigned activity

The portal will redirect to a URL like:

```
<external_activity_url>
  &token=eyJhbGciOiJIUzI1NiJ9.<payload>.<signature>
  &domain=http://127.0.0.1:3000/
  &domain_uid=<user_id>
```

## Troubleshooting

| Symptom | Likely cause |
|---------|-------------|
| Runtime shows auth/login error | Port 3000 not reachable from browser. Try making port public in Codespaces Ports tab. |
| "No HMAC signing secret" in portal logs | `JWT_HMAC_SECRET` not set in the container environment. Restart with `docker compose down && docker compose up -d`. |
| Mixed content blocked (visible in DevTools console) | HTTPS runtime calling HTTP `127.0.0.1`. Make port 3000 public and use the `https://` codespace URL instead. |
| Activity Player shows blank / can't load activity | The `?activity=` URL points to an inaccessible JSON endpoint. Verify the URL loads in a browser tab. |
| Firebase token request fails (500) | `FirebaseApp` record missing or has invalid credentials. Check `http://127.0.0.1:3000/admin/firebase_apps`. |
| Firebase token request fails (400) | Missing `firebase_app` parameter. This is a runtime-side issue — the runtime should be sending this parameter. |
| Student answers not saving | Firebase credentials may be invalid or expired. Re-copy from staging. |
| No "Run" button for student | Activity not assigned to the student's class, or student not enrolled. |

## Testing without Firebase (partial test)

If you only need to verify the JWT launch token exchange and don't want to set up Firebase apps, you can skip the Firebase setup steps (4a or 5b). The runtime will load and authenticate with the portal successfully, but will fail when trying to save student data. Watch the Network tab to confirm:

- `GET /api/v1/jwt/portal` succeeds (200) — this confirms the JWT launch token works
- `GET /api/v1/jwt/firebase` fails (500) — expected without Firebase setup

This is sufficient to verify that the JWT token generation and the `check_for_auth_token` routing changes work correctly.
