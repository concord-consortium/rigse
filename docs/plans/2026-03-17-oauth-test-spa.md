# OAuth Test SPA Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a minimal test SPA that exercises the Portal's OAuth2 launch flow (authDomain, resourceLinkId, loginHint) and displays the authenticated user's name.

**Architecture:** A single self-contained HTML file in `rails/public/oauth-test/` with inline JavaScript. A rake task registers the OAuth client. The SPA follows CLUE's sessionStorage-based OAuth2 implicit grant pattern.

**Tech Stack:** Plain HTML + vanilla JavaScript. No build tools, no external dependencies.

---

### Task 1: Register the OAuth Test SPA Client

**Files:**
- Modify: `rails/lib/tasks/app.rake:129` (add task and update local_setup)

**Step 1: Add the rake task**

Add a new task inside the `app:setup` namespace, before the `local_setup` line:

```ruby
desc "create OAuth test SPA client"
task :create_oauth_test_client => :environment do
  Client.where(name: "OAuth Test SPA").first_or_create(
    app_id: "oauth-test-spa",
    app_secret: SecureRandom.uuid(),
    client_type: "public",
    domain_matchers: "localhost.*",
    redirect_uris: "http://localhost:3000/oauth-test/index.html"
  )
end
```

Update the `local_setup` line to include the new task:

```ruby
task :local_setup => [:create_default_external_reports, :create_default_tools, :create_oauth_test_client, 'sso:add_dev_client']
```

**Step 2: Run the rake task to verify it works**

Run: `docker compose exec app bundle exec rake app:setup:create_oauth_test_client`
Expected: No errors. Client created in DB.

**Step 3: Verify the client exists**

Run: `docker compose exec app bundle exec rails runner "puts Client.find_by(app_id: 'oauth-test-spa').inspect"`
Expected: Client record with name "OAuth Test SPA", client_type "public", domain_matchers "localhost.*"

**Step 4: Commit**

```bash
git add rails/lib/tasks/app.rake
git commit -m "add rake task to register OAuth test SPA client"
```

---

### Task 2: Create the OAuth Test SPA

**Files:**
- Create: `rails/public/oauth-test/index.html`

**Step 1: Create the SPA file**

Create `rails/public/oauth-test/index.html` — a single self-contained HTML file with inline JavaScript that implements the OAuth2 implicit grant flow.

The SPA has three states:

**State A — Launch detected (has `authDomain` param, no `access_token` in hash):**
1. Display the detected launch params (authDomain, resourceLinkId, loginHint)
2. Save all URL search params to `sessionStorage` under key `oauth_test_spa_params`
3. Generate a random `state` value and save it to `sessionStorage` under key `oauth_test_spa_state`
4. Redirect to `{authDomain}/auth/oauth_authorize` with query params:
   - `client_id=oauth-test-spa`
   - `redirect_uri={window.location.origin + window.location.pathname}` (just the page URL, no query/hash)
   - `response_type=token`
   - `state={random}`
   - `login_hint={loginHint}` (if present in launch params)

**State B — OAuth2 callback (has `#access_token` in URL hash):**
1. Parse the URL hash fragment to extract `access_token`, `token_type`, `state`
2. Verify `state` matches what was saved in `sessionStorage`
3. Restore saved params from `sessionStorage`
4. Retrieve `authDomain` from restored params
5. Fetch `GET {authDomain}/auth/user` with `Authorization: Bearer {access_token}` header
6. Display "Welcome {extra.full_name}"
7. Display debug info: access token, restored params (authDomain, resourceLinkId, loginHint)
8. Clean URL hash (replace with clean URL)

**State C — No launch params and no callback:**
1. Display instructions: how to use the SPA with example URL

Implementation notes:
- Use `fetch()` for the API call
- Handle errors gracefully (display error message if fetch fails or state mismatch)
- The `auth/user` endpoint requires the `Referer` header to match the client's `domain_matchers` — `fetch()` from the same origin will include this automatically
- Keep the HTML minimal: no CSS framework, just basic structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>OAuth Test SPA</title>
</head>
<body>
  <h1>OAuth Test SPA</h1>
  <div id="status"></div>
  <div id="result"></div>
  <div id="debug"></div>

  <script>
    const STORAGE_PARAMS_KEY = 'oauth_test_spa_params';
    const STORAGE_STATE_KEY = 'oauth_test_spa_state';
    const CLIENT_ID = 'oauth-test-spa';

    const statusEl = document.getElementById('status');
    const resultEl = document.getElementById('result');
    const debugEl = document.getElementById('debug');

    function parseHash(hash) {
      const params = {};
      if (!hash || hash.length <= 1) return params;
      const pairs = hash.substring(1).split('&');
      for (const pair of pairs) {
        const [key, value] = pair.split('=').map(decodeURIComponent);
        params[key] = value;
      }
      return params;
    }

    function showStatus(msg) {
      statusEl.innerHTML += '<p>' + msg + '</p>';
    }

    function showResult(msg) {
      resultEl.innerHTML = '<h2>' + msg + '</h2>';
    }

    function showDebug(label, data) {
      debugEl.innerHTML += '<h3>' + label + '</h3><pre>' +
        JSON.stringify(data, null, 2) + '</pre>';
    }

    function showInstructions() {
      const exampleUrl = window.location.origin + window.location.pathname +
        '?authDomain=' + encodeURIComponent(window.location.origin) +
        '&resourceLinkId=123&loginHint=1';
      statusEl.innerHTML =
        '<h2>Usage</h2>' +
        '<p>Open this page with OAuth2 launch parameters:</p>' +
        '<p><a href="' + exampleUrl + '">' + exampleUrl + '</a></p>' +
        '<p>Parameters:</p>' +
        '<ul>' +
        '<li><b>authDomain</b> (required) — Portal URL for OAuth2</li>' +
        '<li><b>resourceLinkId</b> (optional) — Offering ID</li>' +
        '<li><b>loginHint</b> (optional) — Expected user ID</li>' +
        '</ul>';
    }

    async function handleCallback(hashParams) {
      const savedState = sessionStorage.getItem(STORAGE_STATE_KEY);
      if (hashParams.state !== savedState) {
        showStatus('Error: state mismatch (expected ' + savedState +
          ', got ' + hashParams.state + ')');
        return;
      }

      const savedParamsJson = sessionStorage.getItem(STORAGE_PARAMS_KEY);
      const savedParams = savedParamsJson ? JSON.parse(savedParamsJson) : {};

      sessionStorage.removeItem(STORAGE_PARAMS_KEY);
      sessionStorage.removeItem(STORAGE_STATE_KEY);

      // Clean URL
      history.replaceState(null, '', window.location.pathname);

      const accessToken = hashParams.access_token;
      const authDomain = savedParams.authDomain;

      showStatus('Authenticated. Fetching user info...');
      showDebug('Access Token', accessToken);
      showDebug('Restored Launch Params', savedParams);

      try {
        const response = await fetch(authDomain + '/auth/user', {
          headers: { 'Authorization': 'Bearer ' + accessToken }
        });
        if (!response.ok) {
          throw new Error('HTTP ' + response.status + ': ' + response.statusText);
        }
        const user = await response.json();
        showResult('Welcome ' + user.extra.full_name);
        showDebug('User Info', user);
      } catch (err) {
        showStatus('Error fetching user: ' + err.message);
      }
    }

    function startOAuth(params) {
      const authDomain = params.get('authDomain');

      showStatus('Launch params detected. Redirecting to Portal for authentication...');
      showDebug('Launch Params', Object.fromEntries(params));

      // Save params
      const paramsObj = Object.fromEntries(params);
      sessionStorage.setItem(STORAGE_PARAMS_KEY, JSON.stringify(paramsObj));

      // Generate and save state
      const state = Math.random().toString(36).substring(2);
      sessionStorage.setItem(STORAGE_STATE_KEY, state);

      // Build redirect URI (just the page, no query or hash)
      const redirectUri = window.location.origin + window.location.pathname;

      // Build authorize URL
      const authorizeUrl = authDomain + '/auth/oauth_authorize?' +
        'client_id=' + encodeURIComponent(CLIENT_ID) +
        '&redirect_uri=' + encodeURIComponent(redirectUri) +
        '&response_type=token' +
        '&state=' + encodeURIComponent(state) +
        (params.get('loginHint')
          ? '&login_hint=' + encodeURIComponent(params.get('loginHint'))
          : '');

      window.location.href = authorizeUrl;
    }

    // Main
    (function() {
      const hashParams = parseHash(window.location.hash);
      const searchParams = new URLSearchParams(window.location.search);

      if (hashParams.access_token) {
        // State B: OAuth2 callback
        handleCallback(hashParams);
      } else if (searchParams.get('authDomain')) {
        // State A: Launch detected
        startOAuth(searchParams);
      } else {
        // State C: No params
        showInstructions();
      }
    })();
  </script>
</body>
</html>
```

**Step 2: Verify the file is served**

Open in browser: `http://localhost:3000/oauth-test/index.html`
Expected: Instructions page with example URL

**Step 3: Commit**

```bash
git add rails/public/oauth-test/index.html
git commit -m "add OAuth test SPA for testing OAuth2 launch flow"
```

---

### Task 3: Manual End-to-End Test

**Prerequisites:**
- Portal running locally (`docker compose up`)
- Client registered (Task 1 rake task has been run)
- A user account exists in the local Portal

**Step 1: Test the full flow**

Open: `http://localhost:3000/oauth-test/index.html?authDomain=http://localhost:3000&resourceLinkId=123&loginHint=1`

Expected sequence:
1. Page briefly shows "Launch params detected" then redirects to Portal
2. If not logged in: Portal login page appears (with "OAuth Test SPA" app name)
3. After login: redirects back to the SPA with `#access_token=...`
4. SPA shows "Welcome [your name]"
5. Debug section shows access token and restored params

**Step 2: Test login_hint mismatch**

Log in as one user, then open the SPA with a different user's ID as loginHint:
`http://localhost:3000/oauth-test/index.html?authDomain=http://localhost:3000&resourceLinkId=123&loginHint=99999`

Expected: Portal shows the login_hint mismatch warning page with "Continue" and "Log in as different user" options.

**Step 3: Test state mismatch protection**

Manually craft a callback URL with a wrong state value:
`http://localhost:3000/oauth-test/index.html#access_token=fake&state=wrong`

Expected: SPA shows "Error: state mismatch" message.
