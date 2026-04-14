# OAuth Test SPA Design

**Date:** 2026-03-17
**Status:** Approved
**Related:** `2026-03-06-oauth2-launch-design.md`

---

## Purpose

A minimal test SPA to manually verify the OAuth2 launch flow implemented on the `RIGSE-337-oauth-launch` branch. It replicates what CLUE does with OAuth2 launch parameters (`authDomain`, `resourceLinkId`, `loginHint`) and displays the authenticated user's name.

## Files

1. **`rails/public/oauth-test/index.html`** — Single self-contained HTML file (inline JS, no external dependencies)
2. **`rails/lib/tasks/app.rake`** — New `app:setup:create_oauth_test_client` rake task, added to the `local_setup` chain

## Client Registration

A new rake task `app:setup:create_oauth_test_client` registers a public OAuth client:

- `name`: "OAuth Test SPA"
- `app_id`: "oauth-test-spa"
- `client_type`: "public"
- `domain_matchers`: "localhost.*"

Uses `Client.where(name:).first_or_create` pattern consistent with existing tasks.

## SPA Flow

1. SPA loads with URL params: `?authDomain=http://localhost:3000&resourceLinkId=123&loginHint=456`
2. Detects `authDomain`, saves all URL params to `sessionStorage`
3. Redirects to `{authDomain}/auth/oauth_authorize?client_id=oauth-test-spa&redirect_uri={thisPage}&response_type=token&state={random}`
4. Portal authenticates (login if needed, login_hint mismatch check) and redirects back with `#access_token=...&token_type=bearer&state=...`
5. SPA extracts access token from URL hash, restores params from `sessionStorage`, verifies `state`
6. Calls `GET {authDomain}/auth/user` with `Authorization: Bearer {token}`
7. Displays "Welcome [full_name]" plus debug info (token, restored params)

## What the Page Shows

- Detected launch params (authDomain, resourceLinkId, loginHint)
- Auth status and any errors
- After success: "Welcome [name]" and debug details (access token, restored params)
