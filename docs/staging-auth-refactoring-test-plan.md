# Staging Test Plan — Auth Refactoring

**PRs:**
- [#1465 — Remove peer-to-peer auth from check_for_auth_token](https://github.com/concord-consortium/rigse/pull/1465)
- [#1466 — Replace client-less AccessGrants with JWT launch tokens](https://github.com/concord-consortium/rigse/pull/1466)

**What changed in summary:**
- Activity launch tokens are now stateless JWTs instead of database-backed AccessGrant records
- Bearer token routing detects dots to distinguish JWTs from hex AccessGrant tokens
- Devise strategies updated to accept JWT Bearer tokens (not just `Bearer/JWT` prefix)
- Peer-to-peer auth paths removed (zero traffic over 365 days of logs)
- `User#create_access_token_with_learner_valid_for` removed (no remaining callers)

---

## 1. Activity Launches

### 1a. Launch an external activity as a student
- Assign an external activity (e.g., Activity Player activity) to a class
- Log in as a student in that class and launch the activity
- **Verify:** Activity loads and runs normally
- **Verify:** The `token` URL parameter is a JWT (three dot-separated segments, not a hex string)
- **Verify (DevTools Network tab):** `GET /api/v1/jwt/portal` returns 200/201 with a longer-lived JWT
- **Verify (DevTools Network tab):** `GET /api/v1/jwt/firebase` returns 200/201 with a Firebase JWT
- **Verify:** Student work saves successfully (Firestore write completes)

### 1b. Launch the same activity a second time
- Re-launch the same activity after initial run
- **Verify:** Previous student work is still present (data persistence unaffected)
- **Verify:** New JWT is issued (token in URL differs from first launch)

### 1c. Launch a different external activity as a student
- Try a second external activity to confirm this isn't activity-specific
- **Verify:** Same successful behavior as 1a

### 1d. Launch an activity as a teacher (preview/run mode)
- Log in as a teacher and preview or run an assigned activity
- **Verify:** Activity loads, teacher context is correct

---

## 2. Collaborative Activities

### 2a. Create a collaboration
- Assign a collaborative activity to a class
- Launch as a student; create or join a collaboration
- **Verify:** Collaboration is created successfully
- **Verify:** The collaboration launch URL contains a JWT token
- **Verify:** Collaborating students can see shared work

---

## 3. Report Launches (should be unchanged)

### 3a. Launch a report as a teacher
- As a teacher, view a report for an offering (e.g., from the class page)
- **Verify:** Report loads and shows student data
- **Verify:** The report URL contains an AccessGrant token (hex format, no dots — these are NOT affected by the refactoring)

### 3b. Launch a report as a researcher/admin
- If applicable, view a report as a researcher or admin user
- **Verify:** Report loads normally

---

## 4. OAuth2 Client Flows (should be unchanged)

### 4a. Public client implicit grant (e.g., CLUE)
- Launch a CLUE activity as a student (from tests in section 1)
- After CLUE loads, reload the page — CLUE updates the URL after launch, so a reload triggers an OAuth2 implicit flow (`response_type=token`) to get a new token
- **Verify:** After reload, CLUE re-authenticates and loads successfully
- **Verify:** Student work is still accessible after the reload

### 4b. Confidential client authorization code grant (e.g., LARA)
- Log in through the staging portal from staging LARA
- **Verify:** OAuth2 code flow still works for clients with `client_id`

---

## 5. Portal UI / Session Auth (should be unchanged)

### 5a. Student login and dashboard
- Log in as a student via the Portal UI
- **Verify:** Dashboard loads, assigned classes and activities are visible

### 5b. Teacher login and class management
- Log in as a teacher via the Portal UI
- **Verify:** Class management, student roster, and offering assignment all work

### 5c. Admin login
- Log in as an admin
- **Verify:** Admin pages load normally

---

## 6. Removed Peer-to-Peer Auth (confirm no regressions)

### 6a. Learner details endpoint
- `GET /admin/learner_details/:id` should return 403 (disabled in policy)
- This was already unused; just confirm it doesn't 500

### 6b. Collaboration data endpoint (preserved)
- The `collaborators_data` endpoint used by report-service's auto-importer should still work
- This peer auth path was intentionally kept
- This should be testable by running an AP activity as a group, and then run it as the second user by themselves. The answers should show up in this second user's activty. Also running the teacher report should show the second user's work. 
- **Verify:** Report-service auto-importer can still fetch collaboration data (if testable on staging)

---

## 7. Edge Cases

### 7a. Expired launch token
- Launch an activity, copy the JWT from the URL
- Wait 4+ minutes (launch tokens expire in 3 minutes)
- Try using the expired token directly against `/api/v1/jwt/portal`
- **Verify:** Request fails with an appropriate error (not a 500)

### 7b. Browser back/forward after launch
- Launch an activity, then use browser back button
- Re-launch the activity
- **Verify:** New token is generated, activity loads normally

---

## 8. Auth Logging Verification

### 8a. Session auth log line
- Log in as any user via the Portal UI and navigate to a page (e.g., `/admin`)
- **Verify (Rails logs):** An `Auth: user=<id> GET /admin` line appears near the Completed line

### 8b. Bearer token auth log line
- Launch an activity that uses a bearer token (e.g., Activity Player OAuth2 implicit flow)
- **Verify (Rails logs):** `Auth: user=<id> auth=bearer_token client=<client_name> GET /api/v1/...` appears

### 8c. JWT bearer token auth log line
- Launch an activity — the initial launch uses a JWT bearer token for `/api/v1/jwt/portal`
- **Verify (Rails logs):** `Auth: user=<id> auth=jwt_bearer_token GET /api/v1/jwt/portal` appears

### 8d. API JWT auth log line
- After a JWT is obtained via `/api/v1/jwt/portal`, the activity uses it for subsequent API calls
- **Verify (Rails logs):** `Auth: user=<id> auth=api_jwt GET /api/v1/...` appears

### 8e. Auth failure warn logs
- Attempt an API call with an invalid or expired token
- **Verify (Rails logs):** A `WARN` level message like `API auth failed:` or `JwtBearerToken: decode error` appears

### 8f. Unauthenticated requests
- Visit a public page without logging in
- **Verify (Rails logs):** No `Auth:` line appears for the request

---

## What to Watch For

- **500 errors** on any launch or authentication path
- **"You must be logged in"** errors during activity launches that previously worked
- **Blank screens** in Activity Player (could indicate failed token exchange)
- **Missing student data** in reports (could indicate report token path regression)
- **Rails logs:** Look for `JwtBearerToken: decode error` or `BearerToken: referer rejected` warnings (new logging from Devise strategies)
