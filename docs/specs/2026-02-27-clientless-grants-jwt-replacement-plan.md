# Client-less Grants JWT Replacement — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace client-less AccessGrant launch tokens with stateless JWTs at the two creation sites, and update `check_for_auth_token` to route Bearer tokens containing dots to JWT decoding.

**Architecture:** Expand the `Bearer/JWT` case in `check_for_auth_token` to also match `Bearer <token>` when the token contains dots (JWTs always have dots; hex AccessGrant tokens never do). Replace the two grant creation sites with `SignedJwt::create_portal_token`. Remove the now-unused `User#create_access_token_with_learner_valid_for` method.

**Tech Stack:** Rails, RSpec, `jwt` gem via `SignedJwt` module

---

### Task 1: Update `check_for_auth_token` to route JWT Bearer tokens

**Files:**
- Modify: `rails/app/controllers/api/api_controller.rb:26-65`
- Test: `rails/spec/controllers/api/api_controller_spec.rb`

**Step 1: Write the failing test**

Add a new context to `api_controller_spec.rb` inside the existing `check_for_auth_token` describe block, after the existing JWT Bearer/JWT tests:

```ruby
describe "standard bearer token with JWT (dot-containing token)" do
  it "should decode a JWT sent as a plain Bearer token" do
    claims = {user_type: "learner", learner_id: learner.id}
    jwt_token = SignedJwt.create_portal_token(user, claims, 3600)
    set_standard_bearer_token(jwt_token)
    auth_user, auth_roles = controller.check_for_auth_token({})
    expect(auth_user).to eq(user)
    expect(auth_roles[:learner]).to eq(learner)
    expect(auth_roles[:teacher]).to be_nil
  end

  it "should still route hex tokens to AccessGrant lookup" do
    token = addTokenForLearner(user, client, learner, 1.hour.from_now)
    set_standard_bearer_token(token)
    auth_user, auth_roles = controller.check_for_auth_token({})
    expect(auth_user).to eq(user)
    expect(auth_roles[:learner]).to eq(learner)
  end
end
```

**Step 2: Run test to verify it fails**

Run: `cd rails && bundle exec rspec spec/controllers/api/api_controller_spec.rb -e "standard bearer token with JWT"`
Expected: FAIL — "Cannot find AccessGrant for requested token" (the JWT hits Case A and fails the AccessGrant lookup)

**Step 3: Write minimal implementation**

In `api_controller.rb`, reorder the cases so JWT detection comes first. Change:

```ruby
if header && header =~ /^Bearer (.*)$/i
  token = $1
  grant = AccessGrant.find_by_access_token(token)
  # ... AccessGrant logic ...
elsif header && header =~ /^Bearer\/JWT (.*)$/i
  portal_token = $1
  # ... JWT logic ...
```

To:

```ruby
if header && (header =~ /^Bearer\/JWT (.*)$/i || (header =~ /^Bearer (.+\..+)$/i))
  portal_token = $1
  # ... existing JWT decode logic (unchanged) ...
elsif header && header =~ /^Bearer (.*)$/i
  token = $1
  grant = AccessGrant.find_by_access_token(token)
  # ... existing AccessGrant logic (unchanged) ...
```

**Step 4: Run tests to verify they pass**

Run: `cd rails && bundle exec rspec spec/controllers/api/api_controller_spec.rb`
Expected: ALL pass (new tests + existing Bearer/JWT and AccessGrant tests)

**Step 5: Commit**

```
git add rails/app/controllers/api/api_controller.rb rails/spec/controllers/api/api_controller_spec.rb
git commit -m "route Bearer tokens with dots to JWT decoding in check_for_auth_token"
```

---

### Task 2: Replace token creation in `external_activity.rb`

**Files:**
- Modify: `rails/app/models/external_activity.rb:148-153`
- Test: `rails/spec/models/external_activity_spec.rb`

**Step 1: Write the failing test**

Add a new test in `external_activity_spec.rb` inside the `"url transforms"` describe block:

```ruby
it "should append a JWT token when append_auth_token is true" do
  user = FactoryBot.create(:confirmed_user)
  learner = mock_model(Portal::Learner, id: 34, user: user)
  activity.append_auth_token = true
  url = activity.url(learner)
  uri = URI.parse(url)
  query = URI.decode_www_form(uri.query)
  token_param = query.find { |k, _| k == "token" }
  expect(token_param).not_to be_nil
  # JWT tokens contain dots (header.payload.signature)
  expect(token_param[1]).to include(".")
  # Verify it's a valid portal JWT with learner claims
  decoded = SignedJwt.decode_portal_token(token_param[1])
  expect(decoded[:data]["uid"]).to eq(user.id)
  expect(decoded[:data]["learner_id"]).to eq(34)
  expect(decoded[:data]["user_type"]).to eq("learner")
end
```

**Step 2: Run test to verify it fails**

Run: `cd rails && bundle exec rspec spec/models/external_activity_spec.rb -e "should append a JWT token"`
Expected: FAIL — token is a 32-char hex string (no dots), `SignedJwt.decode_portal_token` raises

**Step 3: Write minimal implementation**

In `external_activity.rb:148-153`, change:

```ruby
if append_auth_token
  AccessGrant.prune!
  token = learner.user.create_access_token_with_learner_valid_for(3.minutes, learner)
  append_query(uri, "token=#{token}")
```

To:

```ruby
if append_auth_token
  token = SignedJwt::create_portal_token(learner.user, {learner_id: learner.id, user_type: "learner"}, 180)
  append_query(uri, "token=#{token}")
```

**Step 4: Run tests to verify they pass**

Run: `cd rails && bundle exec rspec spec/models/external_activity_spec.rb`
Expected: ALL pass

**Step 5: Commit**

```
git add rails/app/models/external_activity.rb rails/spec/models/external_activity_spec.rb
git commit -m "replace client-less AccessGrant with JWT in external_activity launch"
```

---

### Task 3: Replace token creation in `create_collaboration.rb`

**Files:**
- Modify: `rails/app/services/api/v1/create_collaboration.rb:80-83`
- Test: `rails/spec/services/api/v1/create_collaboration_spec.rb`

**Step 1: Update the existing test assertion**

The existing test at line 103-129 already tests the `append_auth_token` path. Update the assertion to verify the token is a JWT:

```ruby
# Replace this:
token_param, token = query.pop()
expect(token_param).to eq("token")
expect(token).not_to be_nil

# With this:
token_param, token = query.pop()
expect(token_param).to eq("token")
expect(token).to include(".")
decoded = SignedJwt.decode_portal_token(token)
expect(decoded[:data]["uid"]).to eq(student1.user.id)
expect(decoded[:data]["learner_id"]).not_to be_nil
expect(decoded[:data]["user_type"]).to eq("learner")
```

**Step 2: Run test to verify it fails**

Run: `cd rails && bundle exec rspec spec/services/api/v1/create_collaboration_spec.rb -e "should also generate external activity URL with a token"`
Expected: FAIL — token is hex (no dots)

**Step 3: Write minimal implementation**

In `create_collaboration.rb:80-83`, change:

```ruby
if @offering.runnable.append_auth_token
  AccessGrant.prune!
  token = @owner_learner.user.create_access_token_with_learner_valid_for(3.minutes, @owner_learner)
  external_activity_url = add_param(external_activity_url, 'token', token)
end
```

To:

```ruby
if @offering.runnable.append_auth_token
  token = SignedJwt::create_portal_token(@owner_learner.user, {learner_id: @owner_learner.id, user_type: "learner"}, 180)
  external_activity_url = add_param(external_activity_url, 'token', token)
end
```

**Step 4: Run tests to verify they pass**

Run: `cd rails && bundle exec rspec spec/services/api/v1/create_collaboration_spec.rb`
Expected: ALL pass

**Step 5: Commit**

```
git add rails/app/services/api/v1/create_collaboration.rb rails/spec/services/api/v1/create_collaboration_spec.rb
git commit -m "replace client-less AccessGrant with JWT in create_collaboration"
```

---

### Task 4: Remove `User#create_access_token_with_learner_valid_for`

**Files:**
- Modify: `rails/app/models/user.rb:300-303`
- Modify: `rails/spec/models/user_spec.rb` (remove the skipped test)

**Step 1: Remove the method**

Delete lines 300-303 from `user.rb`:

```ruby
# Creates a new access token valid for given time with an associated learner.
def create_access_token_with_learner_valid_for(time, learner)
  return access_grants.create!(access_token_expires_at: time.from_now + 1.second, learner_id: learner.id).access_token
end
```

**Step 2: Remove the skipped test**

Delete the `xit` block for `create_access_token_with_learner_valid_for` from `user_spec.rb`.

**Step 3: Run tests to verify nothing breaks**

Run: `cd rails && bundle exec rspec spec/models/user_spec.rb spec/models/external_activity_spec.rb spec/services/api/v1/create_collaboration_spec.rb spec/controllers/api/api_controller_spec.rb`
Expected: ALL pass

**Step 4: Commit**

```
git add rails/app/models/user.rb rails/spec/models/user_spec.rb
git commit -m "remove unused User#create_access_token_with_learner_valid_for"
```
