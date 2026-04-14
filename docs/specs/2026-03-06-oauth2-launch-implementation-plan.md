# OAuth2 Launch Support Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add OAuth2 launch support to ExternalActivities via a `launch_method` field on the Tool model, with `loginHint` identity verification in the `oauth_authorize` endpoint to prevent stale-tab user mismatch.

**Architecture:** New `launch_method` string column on the Tool model. When set to `"oauth2"`, `ExternalActivity#url` appends `authDomain`, `resourceLinkId`, and `loginHint` instead of the current `token`/`domain`/`domain_uid` parameters. The `oauth_authorize` endpoint checks `login_hint` against the current user and shows a warning page on mismatch.

**Tech Stack:** Rails, RSpec, HAML views, MySQL migrations

**Design doc:** `docs/specs/2026-03-06-oauth2-launch-design.md`

**Already completed:** Tasks 1-3 from the original plan are done and committed:
- Migration adding `launch_method` column to tools
- `oauth2_tool` factory and `:launch_method` in strong params
- Failing tests for OAuth2 launch URL generation (need updating to include `loginHint`)

---

### Task 4: Update tests to include `loginHint` and implement OAuth2 launch URL generation

**Files:**
- Modify: `rails/spec/models/external_activity_spec.rb` (update OAuth2 tests to expect `loginHint`)
- Modify: `rails/app/models/external_activity.rb:142-158` (update `url` method)

**Step 1: Update the existing failing tests to also expect `loginHint`**

In `rails/spec/models/external_activity_spec.rb`, update the first OAuth2 test (around line 87) to also check for `loginHint`:

In the test `"should append authDomain and resourceLinkId when tool launch_method is oauth2"`, add after the `resourceLinkId` assertions:

```ruby
login_hint = query.find { |k, _| k == "loginHint" }
expect(login_hint).not_to be_nil
expect(login_hint[1]).to eq(user.id.to_s)
```

In the test `"should return the base url without authDomain when domain is nil"` (around line 121), add:

```ruby
expect(query_string).to include("loginHint=")
```

**Step 2: Run tests to verify they still fail**

Run:
```bash
docker compose run --rm app bundle exec rspec spec/models/external_activity_spec.rb -e "oauth2"
```

Expected: Tests fail because `ExternalActivity#url` does not yet handle `launch_method == "oauth2"`.

**Step 3: Implement the `url` method changes**

Replace the `url` method in `rails/app/models/external_activity.rb` (lines 142-158) with:

```ruby
def url(learner = nil, domain = nil)
  begin
    uri = URI.parse(read_attribute(:url))
    if learner
      if self.tool&.launch_method == "oauth2"
        append_query(uri, "authDomain=#{domain}") if domain
        append_query(uri, "resourceLinkId=#{learner.offering.id}")
        append_query(uri, "loginHint=#{learner.user.id}")
        return uri.to_s
      end

      append_query(uri, "learner=#{learner.id}") if append_learner_id_to_url
      append_query(uri, "c=#{learner.user.id}") if append_survey_monkey_uid
      if append_auth_token
        token = SignedJwt::create_portal_token(learner.user, {learner_id: learner.id, user_type: "learner"}, 180)
        append_query(uri, "token=#{token}")
        append_query(uri, "domain=#{domain}&domain_uid=#{learner.user.id}") if domain
      end
    end
    return uri.to_s
  rescue
    return read_attribute(:url)
  end
end
```

**Step 4: Run OAuth2 tests to verify they pass**

Run:
```bash
docker compose run --rm app bundle exec rspec spec/models/external_activity_spec.rb -e "oauth2"
```

Expected: All OAuth2 tests pass.

**Step 5: Run the full ExternalActivity spec to verify no regressions**

Run:
```bash
docker compose run --rm app bundle exec rspec spec/models/external_activity_spec.rb
```

Expected: All tests pass.

**Step 6: Commit**

```bash
git add rails/spec/models/external_activity_spec.rb rails/app/models/external_activity.rb
git commit -m "implement OAuth2 launch URL generation with loginHint in ExternalActivity#url"
```

---

### Task 5: Write failing tests for login_hint check in oauth_authorize

**Files:**
- Modify: `rails/spec/controllers/auth_controller_spec.rb` (add login_hint tests)

**Step 1: Write the failing tests**

Add to the existing `describe '#oauth_authorize'` block in `rails/spec/controllers/auth_controller_spec.rb`, after the existing `without a logged in user` context (after line 66):

```ruby
context 'with a logged in user' do
  let(:user) { FactoryBot.create(:confirmed_user) }
  let(:client) { FactoryBot.create(:client, name: 'Test App', app_id: 'test-client', :redirect_uris => 'http://test.host/redirect') }

  before(:each) do
    sign_in user
    # Stub the redirect URI generation so oauth_authorize can proceed
    allow(AccessGrant).to receive(:get_authorize_redirect_uri)
      .and_return("http://test.host/redirect#access_token=test&token_type=bearer")
  end

  context 'without login_hint' do
    let(:params) { { client_id: client.app_id, redirect_uri: 'http://test.host/redirect', response_type: 'token' } }

    it 'redirects normally' do
      get :oauth_authorize, params: params
      expect(response).to have_http_status(:redirect)
    end
  end

  context 'with login_hint matching current user' do
    let(:params) { { client_id: client.app_id, redirect_uri: 'http://test.host/redirect', response_type: 'token', login_hint: user.id.to_s } }

    it 'redirects normally' do
      get :oauth_authorize, params: params
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('access_token')
    end
  end

  context 'with login_hint not matching current user' do
    let(:params) { { client_id: client.app_id, redirect_uri: 'http://test.host/redirect', response_type: 'token', login_hint: '99999' } }

    it 'renders the login_hint_mismatch page' do
      get :oauth_authorize, params: params
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('auth/login_hint_mismatch')
    end

    it 'passes the current user name to the view' do
      get :oauth_authorize, params: params
      expect(assigns(:user_name)).to eq(user.name)
    end

    it 'passes a continue URL without login_hint' do
      get :oauth_authorize, params: params
      expect(assigns(:continue_url)).not_to include('login_hint')
      expect(assigns(:continue_url)).to include('client_id')
    end

    it 'passes a switch user URL without login_hint' do
      get :oauth_authorize, params: params
      expect(assigns(:switch_user_url)).not_to include('login_hint')
    end
  end
end
```

**Step 2: Run the tests to verify they fail**

Run:
```bash
docker compose run --rm app bundle exec rspec spec/controllers/auth_controller_spec.rb -e "login_hint"
```

Expected: Tests fail because `oauth_authorize` does not yet handle `login_hint`.

**Step 3: Commit**

```bash
git add rails/spec/controllers/auth_controller_spec.rb
git commit -m "add failing tests for login_hint check in oauth_authorize"
```

---

### Task 6: Implement login_hint check in oauth_authorize

**Files:**
- Modify: `rails/app/controllers/auth_controller.rb:42-62` (update `oauth_authorize` method)
- Create: `rails/app/views/auth/login_hint_mismatch.haml` (warning page)

**Step 1: Update the `oauth_authorize` method**

In `rails/app/controllers/auth_controller.rb`, replace the `oauth_authorize` method (lines 42-62) with:

```ruby
def oauth_authorize
  if current_user.nil?
    validation = AccessGrant.validate_oauth_authorize(params)
    if (!validation.valid)
      redirect_to validation.error_redirect, allow_other_host: true
      return
    end

    # if the parameters are valid then the validation will have a client
    # we send the clients name to the login box so it can display a helpful name
    app_name = validation.client.name
    redirect_to auth_login_path(after_sign_in_path: request.fullpath, app_name: app_name)
    return
  end

  # Check login_hint: if present and doesn't match current user, show warning
  if params[:login_hint].present? && current_user.id.to_s != params[:login_hint]
    @user_name = current_user.name

    # Build continue URL: same params minus login_hint
    continue_params = request.query_parameters.except("login_hint")
    @continue_url = "#{request.path}?#{continue_params.to_query}"

    # Build switch user URL: logout then login, with after_sign_in_path to oauth_authorize without login_hint
    @switch_user_url = logout_path(after_sign_in_path: @continue_url)

    render 'auth/login_hint_mismatch', layout: false
    return
  end

  # Note that we'll get to this point only if user is currently logged in.
  # If user is not logged in, we'll redirect back here after first
  # logging in the user. This redirect happens when in
  # ApplicationController#after_sign_in_path_for
  redirect_to AccessGrant.get_authorize_redirect_uri(current_user, params), allow_other_host: true
end
```

**Step 2: Create the warning page view**

Create `rails/app/views/auth/login_hint_mismatch.haml` using the same standalone styling pattern as `login.haml`:

```haml
!!!
%html{:lang => "en"}
  %head
    %meta{:charset => "utf-8"}/
    %title Account Mismatch
    %script{:src => "https://use.typekit.com/juj7nhw.js"}
    %script
      try{Typekit.load({ async: true });}catch(e){}
    :css
      html, body, div, span, h1, h2, p, a {
        margin: 0;
        padding: 0;
        border: 0;
        font-size: 100%;
        font: inherit;
        vertical-align: baseline;
      }
      a:link, a:visited {
        color: #fff;
        text-decoration: none;
      }
      a:active, a:hover {
        color: #ffc320;
      }
      body {
        line-height: 1;
        background: #f1f1f1;
        color: #3f3f3f;
        font: 300 100% museo-sans, helvetica, arial, sans-serif;
      }
      #page-wrap {
        margin: 2em auto;
        width: 24em;
      }
      #mismatch-box {
        background: #fff;
        margin-bottom: 1em;
        padding: 30px 40px 40px;
      }
      p { font-size: 1em; margin-bottom: 1em; line-height: 1.4; }
      .button {
        background: #ea6d2f;
        border: none;
        color: #fff;
        cursor: pointer;
        display: block;
        font-family: lato, arial, helvetica, sans-serif;
        font-size: 1em;
        font-weight: 500;
        margin-bottom: 10px;
        padding: 10px 20px;
        text-align: center;
        text-decoration: none;
      }
      .button-secondary {
        background: #0592af;
      }
      strong { font-weight: 700; }
  %body
    #page-wrap
      #mismatch-box
        = render_themed_partial 'shared/logo'
        %p
          You are currently logged in as
          %strong= @user_name
          \. The application expected a different user.
        %a.button{:href => @continue_url}
          Continue as #{@user_name}
        %a.button.button-secondary{:href => @switch_user_url}
          Log in as a different user
```

**Step 3: Run the login_hint tests to verify they pass**

Run:
```bash
docker compose run --rm app bundle exec rspec spec/controllers/auth_controller_spec.rb -e "login_hint"
```

Expected: All login_hint tests pass.

**Step 4: Run the full auth controller spec to verify no regressions**

Run:
```bash
docker compose run --rm app bundle exec rspec spec/controllers/auth_controller_spec.rb
```

Expected: All tests pass.

**Step 5: Commit**

```bash
git add rails/app/controllers/auth_controller.rb rails/app/views/auth/login_hint_mismatch.haml
git commit -m "add login_hint identity verification to oauth_authorize endpoint"
```

---

### Task 7: Update Tool admin form and show view

**Files:**
- Modify: `rails/app/views/admin/tools/_form.html.haml` (add `launch_method` field after line 17)
- Modify: `rails/app/views/admin/tools/_show.html.haml` (add `launch_method` display after line 20)

**Step 1: Add `launch_method` to the form**

In `rails/app/views/admin/tools/_form.html.haml`, add after the `source_type` field (after line 17, the `%br` and description text):

```haml
        %li
          = label_tag "launch_method", "Launch Method:"
          = f.select :launch_method, [["Use ExternalActivity settings", nil], ["OAuth2", "oauth2"]], { include_blank: false }
          %br
          Controls how the Portal launches activities with this tool. "Use ExternalActivity settings" preserves legacy behavior. "OAuth2" appends authDomain, resourceLinkId, and loginHint parameters instead of a token.
```

**Step 2: Add `launch_method` to the show view**

In `rails/app/views/admin/tools/_show.html.haml`, add after the Source Type display (after line 20):

```haml
          %li
            Launch Method:
            = tool.launch_method || "Use ExternalActivity settings"
```

**Step 3: Commit**

```bash
git add rails/app/views/admin/tools/_form.html.haml rails/app/views/admin/tools/_show.html.haml
git commit -m "add launch_method field to Tool admin form and show view"
```

---

### Task 8: Update documentation

**Files:**
- Modify: `docs/portal-authentication-unification-design.md` (update Step 3 in Section 9)
- Modify: `docs/external-services.md` (update SPA OAuth2 pattern section)

**Step 1: Update the unification design doc**

In `docs/portal-authentication-unification-design.md`, update Step 3 in Section 9 (Next Steps, around line 405) to note:
- Step 3 is now designed and implemented (reference `specs/2026-03-06-oauth2-launch-design.md`)
- Collaboration launches are deferred — they continue using JWT tokens
- Add a note: OAuth2 launch URLs are reloadable/bookmarkable, but collaborations want fresh group selection on each launch, so `collaborators_data_url` in a persistent URL is problematic
- Note that `login_hint` support was added to `oauth_authorize` to prevent stale-tab user mismatch

**Step 2: Update external-services.md**

In `docs/external-services.md`:
- In the "SPA OAuth2 initialization pattern" section (around line 68), add a note that the Portal's standard OAuth2 launch parameter names are `authDomain`, `resourceLinkId`, and `loginHint` (camelCase), controlled by the Tool model's `launch_method` field
- Note that the Portal's `oauth_authorize` endpoint now supports `login_hint` (snake_case) — when present and mismatched, shows a warning page
- In the Non LARA Runtime section (around line 40), add a note that collaboration launches are not yet migrated to OAuth2 and continue using JWT tokens

**Step 3: Commit**

```bash
git add docs/portal-authentication-unification-design.md docs/external-services.md
git commit -m "update docs with OAuth2 launch design decisions and login_hint support"
```

---

### Task 9: Run full test suite

**Step 1: Run the full test suite**

Run:
```bash
docker compose run --rm app ./docker/dev/run-spec.sh
```

Expected: All tests pass. No regressions from the new `launch_method` column, the `url` method changes, or the `login_hint` check.

**Step 2: If any tests fail, investigate and fix**

The most likely failure points:
- Tests that create Tool records without the new column (should be fine since it defaults to `nil`)
- Tests that mock or stub `oauth_authorize` behavior (check auth_controller_spec.rb)
- Tests that assert on the Tool model's attributes (unlikely since `launch_method` is just a new nullable column)
