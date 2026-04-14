# PR Review Fixes - RIGSE-337-oauth-launch

These changes address Doug's review comments on PR #1471. All code edits are
already applied on this branch. What remains is running the tests and verifying.

## Changes Made

### 1. Change reauth from GET to POST (security fix)
Doug flagged that the `reauth` action performs `sign_out` via GET, bypassing CSRF
protection. Changed to POST with a CSRF-protected form.

**Files changed:**
- `rails/config/routes.rb:18` — `get` changed to `post`
- `rails/app/views/auth/login_hint_mismatch.haml:80-82` — replaced `%a` link with
  `form_tag` + `%button` (Rails automatically includes CSRF token)
- `rails/spec/controllers/auth_controller_spec.rb` — changed `get :reauth` to
  `post :reauth` in both test contexts

### 2. Add @app_name test assertion
Doug noted the tests don't verify `@app_name` is populated from the `client_id`
lookup. Added a test.

**Files changed:**
- `rails/spec/controllers/auth_controller_spec.rb:124-127` — new test:
  `expect(assigns(:app_name)).to eq('Test App')`

### 3. Use ENV for portal URL in rake task
Doug suggested not hardcoding `localhost:3000` in the OAuth test client seed task.

**Files changed:**
- `rails/lib/tasks/app.rake:136` — uses `ENV.fetch('PORTAL_URL', 'http://localhost:3000')`

## What to do next

1. Check out the `RIGSE-337-oauth-launch` branch and cherry-pick or merge these changes
2. Run the auth controller spec:
   ```bash
   docker compose run --rm app bundle exec rspec spec/controllers/auth_controller_spec.rb
   ```
3. Visually check the "Log in as a different user" button styling — it's now a
   `<button>` inside a `<form>` instead of an `<a>` tag. The `.button.button-secondary`
   CSS should still apply but worth confirming.
4. Commit once tests pass.
5. Delete this file before merging.
