# Implementation Plan: Put the researcher's name and username in the access token

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-374
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

### Sign the name and login into a scoped access token

**Summary**: `create_access_token` adds `first_name`, `last_name` and `username` when it signs a scoped token, with the specs that pin both sides and the doc line that names the claims. One commit: the change is a few lines, and the tests are what make it reviewable.

**Files affected**:
- `rails/lib/signed_jwt.rb`: the three claims, inside the existing `if capabilities`, and the method's header comment (R1 to R4).
- `rails/spec/libs/signed_jwt_spec.rb`: the scoped and unscoped unit tests (R8).
- `rails/spec/requests/scoped_oauth_flow_spec.rb`: one new example comparing against `jwt/portal` (R9).
- `rails/spec/controllers/auth_controller_spec.rb`: the unscoped exchange asserts the claims' absence (R9).
- `docs/external-services.md`: one sentence in the Researcher Dashboard section (R10).
- `README.md`: the **Scopes** paragraph (line 692) names the claims and leaves them out of the unscoped token (R10).

**Estimated diff size**: ~32 lines.

`rails/lib/signed_jwt.rb`, `create_access_token`. The header comment gains a sentence, and the one-line `scope` assignment becomes a block that also adds the names:

```ruby
  # The access token /oauth/token issues (RFC 9068). `capabilities` nil issues an unscoped,
  # full-user token. `aud` lists every service whose capability the token carries, rigse
  # always first, and never an assertion's audience: a verifier that accepts any list
  # containing its audience must not take this as one. A scoped token also names its user,
  # for the client to show and never to authorize: the portal JWT's `first_name` and
  # `last_name`, and the login as `username`, `/auth/user`'s key for it.
  def self.create_access_token(user, client_id:, capabilities:, context:, audiences:, expires_in:)
    ...
    payload = { ... unchanged ... }
    if capabilities
      payload[:scope] = capabilities.join(' ')
      payload.merge!(first_name: user.first_name, last_name: user.last_name, username: user.login)
    end
    payload[:context] = context if context
    sign_rs256(payload, typ: ACCESS_TOKEN_TYPE)
  end
```

The values go in as the attributes hold them (R2); `JWT.encode` writes `nil` as `null` and non-ASCII text as UTF-8. `merge!` without a block is safe here: the three keys are new to this payload and the method takes no caller claims.

`rails/spec/libs/signed_jwt_spec.rb`, `describe "RS256 tokens"` (its `user` is `FactoryBot.create(:user)`: `joe`, `user`, a unique `login_...`):

- "issues an access token that decode_portal_token accepts" adds `'first_name' => user.first_name, 'last_name' => user.last_name, 'username' => user.login` to its existing `include`. Catches: dropping any one claim, a misspelled key, and any two values swapped, since the three differ.
- "issues an unscoped access token without a scope claim, and no scoped one without a capability" adds `expect(data.keys & %w[first_name last_name username]).to be_empty` on the unscoped token (decoded once into `data` rather than inline). Catches: moving the merge outside `if capabilities`.

`rails/spec/requests/scoped_oauth_flow_spec.rb`, `describe 'token'`, where `before(:each)` already signs the researcher in. A new example after the exchange test:

```ruby
    it 'names the user as the portal JWT does, with the login as username' do
      data, _header = claims(exchange(authorize['code'])['access_token'])
      post '/api/v1/jwt/portal'
      portal = SignedJwt.decode_portal_token(JSON.parse(response.body)['token'])[:data]
      names = { 'first_name' => researcher.first_name, 'last_name' => researcher.last_name }
      expect(portal).to include(names)
      expect(data).to include(names.merge('username' => researcher.login))
    end
```

`post '/api/v1/jwt/portal'` sends no bearer, so `check_for_auth_token` takes the session, and a researcher who is neither teacher nor student gets the plain-user claims with `first_name` and `last_name`. Asserting the portal JWT against the user's attributes first keeps the comparison from passing on two missing keys. Catches: the dashboard's real code exchange (through `AuthController#issue_access_token`) not carrying the claims, and the access token's names drifting from the portal JWT's.

`rails/spec/controllers/auth_controller_spec.rb`, "exchanges the code once for an unscoped access token": add `expect(data.keys & %w[first_name last_name username]).to be_empty` beside its `not_to have_key('scope')`. Catches: the controller path signing names into an unscoped token.

`docs/external-services.md`, Researcher Dashboard, after "...since `packages:read` is report-server's capability.":

> It also carries the researcher's `first_name`, `last_name` and `username` (the login), which the dashboard reads to show who is signed in; nothing reads them to authorize.

`README.md`, the **Scopes** paragraph. After "...not report-service's `contextId`, which is the class hash." add:

> The token also carries the user's `first_name`, `last_name` and `username` (the login), for the client to show who is signed in; nothing reads them to authorize.

and "gets the same JWT with no `scope` or `context`, a full-user token" becomes "gets the same JWT without `scope`, `context` or the names, a full-user token".

**Verification**: `docker compose run --rm app bundle exec rspec spec/libs/signed_jwt_spec.rb spec/requests/scoped_oauth_flow_spec.rb spec/controllers/auth_controller_spec.rb` passes with one more example than on `master` (77 to 78). With the `merge!` line deleted, the extended scoped unit test and the new request example fail; with it moved outside `if capabilities`, the unscoped unit test and the controller test fail.

## Open Questions

### RESOLVED: Judgment call: where the claims are added
**Context**: The claims could be added by the signer or passed in by its one production caller, `AuthController#issue_access_token`.
**Options considered**:
- A) In `create_access_token`, inside `if capabilities`.
- B) A `claims:` keyword on `create_access_token`, filled by the controller.

**Decision**: A. The signer already decides what a scoped token carries (`scope`), and the spec helpers that call it (`portal_token_helper.rb`, the dashboard controller and request specs) then sign tokens shaped like production's with no change. B adds a parameter whose only caller passes the same three values.

### RESOLVED: Judgment call: a new request example, or extending the exchange test
**Context**: The exchange test already decodes the scoped token's claims.
**Options considered**:
- A) A separate example that also mints the portal JWT.
- B) Add the names and the `jwt/portal` call to the exchange test.

**Decision**: A. The exchange test checks single use and the grant's deletion; a `jwt/portal` call in the middle of it would replace `response` between its assertions and mix two concerns.

## Deployment

Nothing to configure: no setting, migration or stack parameter. A token issued before the deploy keeps its claims until it expires (8 hours at most), so a dashboard page opened earlier shows no user in RD-9's header until it is next loaded (every load runs the code flow again, `start.ts`) or its token expires; `tokenUser()` returns `null` for such a token and the header leaves the user out, which is today's behavior. Rolling back removes the claims the same way.

## Self-Review

Roles: commit reviewer, test writer, Senior Engineer, operator, docs reviewer. The plan was built for real as throwaway code on `9f948f6c0` (the code change and all four spec edits, run in the Docker test environment, then reverted):

- The three named spec files pass, 78 examples where `master` has 77.
- Deleting the `merge!` fails the extended scoped unit test and the new request example; moving it outside `if capabilities` fails the unscoped unit test and the controller test; swapping `first_name` and `last_name` fails the scoped unit test and the request example. Each test the plan names catches the mutation it claims.
- Every spec file that references `SignedJwt` or signs an access token (23 files, 390 examples) passes with the change, so no other spec pins the claim set.

### Operator

#### RESOLVED: Tokens issued before the deploy carry no names
Confirmed against `tokenUser()` on `RD-9-ui-improvements`: a token without the claims yields `null`, and `Brand.tsx` renders no user. Recorded under Deployment above; no code change follows, since the gap closes at the page's next load, or with the token's 8-hour lifetime.

#### RESOLVED: Deployment said "next sign-in" where a reload is enough
RD-9's `start.ts` runs the authorization again on every page load and `oauth.ts` never stores the token, so a reload gets a token with the names at once; only a page left open keeps an old token, up to its 8 hours. Deployment and requirements.md's Out of Scope line on mid-session name changes now say so.

### Docs reviewer

#### RESOLVED: The README's Scopes paragraph would describe the unscoped token wrongly
README line 692 lists what a scoped client's token carries and calls the unscoped one "the same JWT with no `scope` or `context`". With the change, the unscoped token also lacks the three names, so the sentence would understate the difference, and a reader of the paragraph would not learn that every scoped client receives the user's name. R10 and the plan now edit that paragraph too. RIGSE-369 edits README lines 690 and 701 to 707; a throwaway `git merge-file` of this edit and RIGSE-369's against `master`'s README merged with no conflict, so the stories still merge in either order (requirements.md's Technical Notes record this).

### Docs reviewer (second pass)

#### RESOLVED: The README sentence's "It" would refer to `context.id`
The sentence before the insertion point has `context.id` as its subject, so "It also carries the user's `first_name`..." read as a claim about the id. The added sentence now opens "The token also carries". The `external-services.md` sentence keeps "It", since its preceding sentence's subject is the access token.
