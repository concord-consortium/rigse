# Implementation Plan: The portal signing key and the scoped launch token

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-367
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

Six steps, each one commit, in dependency order: the key and the token primitives first, then the researcher gate, then the two places tokens are accepted and minted, then configuration. Nothing here touches `REPORT_SERVICE_BEARER_TOKEN`; see the note at the end.

### Sign and verify RS256 portal tokens by `kid`, with an audience at every call site

**Summary**: Adds the environment's RS256 keypair, lets `create_portal_token` mint an RS256 token for a named audience, and makes `decode_portal_token` take the audience its caller accepts. Tokens carrying a `kid` header are verified against the `kid`-selected public key with RS256 pinned; tokens without one are the legacy HS256 portal tokens and are verified exactly as today. Neither existing call site accepts any RS256 audience yet, so behavior for every current caller is unchanged. Covers R1 to R4, R7a, R10 to R12.

**Files affected**:
- `rails/lib/portal_signing_key.rb` — new: reads the key, its `kid` and any previous verification keys from the environment
- `rails/lib/signed_jwt.rb` — audience constants; `create_portal_token(..., aud:)`; `decode_portal_token(token, aud:)`
- `rails/lib/jwt_bearer_token_authenticatable.rb` — passes `aud: nil`
- `rails/app/controllers/api/api_controller.rb` — `check_for_auth_token(params, aud: nil)`, records the token's scope in `Current`
- `rails/app/models/current.rb` — `token_scope_kind`, `token_scope_id`
- `rails/app/controllers/api/v1/jwt_controller.rb` — `handle_initial_auth(aud: nil)` threads the audience through (both actions still pass `nil` in this step)
- `rails/spec/spec_helper.rb` — a generated test keypair, next to `JWT_HMAC_SECRET = 'foo'`
- `rails/spec/libs/portal_signing_key_spec.rb` — new
- `rails/spec/libs/signed_jwt_spec.rb` — RS256 mint and verify matrix
- `rails/spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb`, `rails/spec/controllers/api/api_controller_spec.rb` — RS256 bearers refused at both call sites
- Existing specs that call `decode_portal_token(token)` gain `aud: nil`: `spec/controllers/api/v1/jwt_controller_spec.rb` (7 calls), `spec/services/api/v1/create_collaboration_spec.rb`, `spec/controllers/api/v1/oidc_mint_controller_spec.rb`, `spec/controllers/api/v1/classes_controller_marker_spec.rb`, `spec/libs/bearer_token/jwt_bearer_token_authenticatable_spec.rb`, `spec/models/external_activity_spec.rb`

**Estimated diff size**: ~330 lines

`rails/lib/portal_signing_key.rb`:

```ruby
# The environment's RS256 keypair, which signs every portal token that is not a legacy
# HS256 one. The private key lives only in rigse's configuration; report-server and the
# report-service function hold the public half as a configured value keyed by kid.
#
# PORTAL_SIGNING_KEY          PEM private key; literal "\n" sequences are accepted so it
#                             fits in one environment value
# PORTAL_SIGNING_KEY_ID       its kid
# PORTAL_PREVIOUS_VERIFY_KEYS optional JSON object of kid => public PEM, for tokens signed
#                             by the previous key during a rotation
#
# Staging and production must not share a keypair, or a staging token verifies in production.
module PortalSigningKey
  ALGORITHM = 'RS256'.freeze

  def self.configured?
    ENV['PORTAL_SIGNING_KEY'].present? && ENV['PORTAL_SIGNING_KEY_ID'].present?
  end

  def self.kid
    ENV['PORTAL_SIGNING_KEY_ID'].presence ||
      raise(SignedJwt::Error, 'No portal signing key id (PORTAL_SIGNING_KEY_ID) found in environment')
  end

  def self.private_key
    pem = ENV['PORTAL_SIGNING_KEY'].presence ||
      raise(SignedJwt::Error, 'No portal signing key (PORTAL_SIGNING_KEY) found in environment')
    parse(pem, 'PORTAL_SIGNING_KEY')
  end

  # Always an OpenSSL::PKey, never a PEM string: the jwt gem verifies an HS256 token
  # signed with the public PEM as its secret when handed the PEM string and an algorithm
  # list that includes HS256 (requirements.md, Verification).
  def self.verification_key(kid)
    verification_keys.fetch(kid) do
      raise SignedJwt::Error, "Unrecognized portal signing key id: #{kid.inspect}"
    end
  end

  def self.verification_keys
    keys = {}
    keys[kid] = private_key.public_key if configured?
    previous = ENV['PORTAL_PREVIOUS_VERIFY_KEYS'].presence
    if previous
      JSON.parse(previous).each do |previous_kid, pem|
        keys[previous_kid] ||= parse(pem, "PORTAL_PREVIOUS_VERIFY_KEYS[#{previous_kid}]")
      end
    end
    keys
  rescue JSON::ParserError => e
    raise SignedJwt::Error, "PORTAL_PREVIOUS_VERIFY_KEYS is not valid JSON: #{e.message}"
  end

  def self.parse(pem, name)
    @parsed ||= {}
    @parsed[pem] ||= OpenSSL::PKey::RSA.new(pem.gsub('\n', "\n"))
  rescue OpenSSL::PKey::RSAError => e
    raise SignedJwt::Error, "#{name} is not a valid RSA key: #{e.message}"
  end
  private_class_method :parse
end
```

`rails/lib/signed_jwt.rb`, the two methods (the Firebase methods are untouched):

```ruby
  # The audiences an RS256 portal token can carry. Each keeps its claim set and its reach
  # apart from the others; no rigse endpoint accepts the two service audiences.
  AUD_RESEARCHER_DASHBOARD      = 'researcher-dashboard'.freeze
  AUD_REPORT_SERVER             = 'report-server'.freeze
  AUD_REPORT_SERVICE_FUNCTIONS  = 'report-service-functions'.freeze
  AUDIENCES = [AUD_RESEARCHER_DASHBOARD, AUD_REPORT_SERVER, AUD_REPORT_SERVICE_FUNCTIONS].freeze

  # Without aud: the legacy HS256 portal token, exactly as before. With aud: an RS256
  # token for that audience, signed by the environment's key and carrying its kid.
  def self.create_portal_token(user, claims={}, expires_in=3600, aud: nil)
    if aud && !AUDIENCES.include?(aud)
      raise SignedJwt::Error.new("Unknown portal token audience: #{aud}")
    end
    now = Time.now.to_i
    # alg stays first in the HS256 payload so a legacy token's bytes do not change
    payload = aud ? {} : { alg: self.hmac_algorithm }
    payload.merge!(
      iss: APP_CONFIG[:site_url],
      iat: now,
      exp: now + expires_in,
      uid: user.id
    )
    payload[:aud] = aud if aud
    claims = claims.dup
    claims[:minted_via_oidc_client_id] ||= Current.minted_via_oidc_client_id if Current.minted_via_oidc_client_id
    claims[:minted_for]                ||= Current.minted_for                if Current.minted_for
    # merge claims into payload, preventing duplicates
    payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
    begin
      if aud
        JWT.encode payload, PortalSigningKey.private_key, PortalSigningKey::ALGORITHM, { kid: PortalSigningKey.kid }
      else
        JWT.encode payload, self.hmac_secret, self.hmac_algorithm
      end
    rescue SignedJwt::Error
      raise
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
    end
  end

  # aud is the RS256 audience this call site accepts, or nil to accept no RS256 token at
  # all. Tokens are routed by the kid header: with one, RS256 is pinned and the key is the
  # one that kid names; without one, HS256 is pinned against JWT_HMAC_SECRET, which is
  # every legacy portal token. The token's own alg never chooses the key.
  def self.decode_portal_token(token, aud:)
    begin
      header = JWT.decode(token, nil, false)[1]
      decoded =
        if header.key?('kid')
          raise SignedJwt::Error.new('This endpoint does not accept RS256 portal tokens') if aud.nil?
          JWT.decode(token, nil, true, { algorithm: PortalSigningKey::ALGORITHM, aud: aud, verify_aud: true }) do |h|
            PortalSigningKey.verification_key(h['kid'])
          end.tap do |d|
            # The gem accepts an aud array containing the expected value; rigse never mints one.
            raise SignedJwt::Error.new('Portal token aud must be a single string') unless d[0]['aud'].is_a?(String)
          end
        else
          JWT.decode token, self.hmac_secret, true, {algorithm: self.hmac_algorithm}
        end
    rescue JWT::ExpiredSignature, SignedJwt::Error
      raise
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
    end
    {data: decoded[0], header: decoded[1]}
  end
```

The HS256 payload keeps its non-standard `alg` claim, so a legacy token's bytes are unchanged; the RS256 payload omits it.

`rails/lib/jwt_bearer_token_authenticatable.rb`: `SignedJwt.decode_portal_token(jwt_token_value, aud: nil)`. An RS256 token presented to any Devise-authenticated controller now fails with `SignedJwt::Error` and `fail!(:invalid_token)` exactly as a forged one does today. Checked on master with a throwaway request spec: a strategy failure does not halt the request, it leaves `current_user` nil, so `/api/v1/classes/mine` answers its ordinary 403 and `jwt/firebase` still reaches `check_for_auth_token`.

`rails/app/models/current.rb`:

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :minted_via_oidc_client_id, :minted_for
  # What an RS256 bearer says it was launched for. A record of the launch, never a grant:
  # every use re-runs the permission check on the scope.
  attribute :token_scope_kind, :token_scope_id
end
```

`rails/app/controllers/api/api_controller.rb`, `check_for_auth_token`:

```ruby
  def check_for_auth_token(params, aud: nil)
    ...
      if SignedJwt.portal_token?(token)
        decoded_token = SignedJwt.decode_portal_token(token, aud: aud)
        data = decoded_token[:data]
        if decoded_token[:header].key?('kid')
          Current.token_scope_kind = data['scope_kind']
          Current.token_scope_id   = data['scope_id']
        end
        ...
```

`auth_not_anonymous` and the helpers built on it keep calling `check_for_auth_token(params)`, so every existing API controller accepts no RS256 token. RIGSE-368's controllers will call it with `aud: SignedJwt::AUD_RESEARCHER_DASHBOARD`.

`rails/app/controllers/api/v1/jwt_controller.rb`: `def handle_initial_auth(aud: nil)` calls `check_for_auth_token(params, aud: aud)`; `portal` and `firebase` call `handle_initial_auth` unchanged in this step.

`rails/spec/spec_helper.rb`, beside `ENV["JWT_HMAC_SECRET"] = 'foo'`:

```ruby
require "openssl"
ENV["PORTAL_SIGNING_KEY"] = OpenSSL::PKey::RSA.generate(2048).to_pem
ENV["PORTAL_SIGNING_KEY_ID"] = 'test-key'
```

The `require` is needed because these lines run before Rails loads; without it every spec file fails at load with `NameError` (found by applying this step as throwaway code).

**Checked before writing this up.** This step and the next were applied as throwaway code and run: `signed_jwt_spec`, `spec/libs/bearer_token`, `api_controller_spec`, `jwt_controller_spec`, `jwt_controller_guard_spec`, `oidc_auth_spec`, `oidc_mint_controller_spec`, `classes_controller_marker_spec`, `create_collaboration_spec` and `external_activity_spec` pass (225 examples, 0 failures) with the `aud: nil` edits as the only spec changes, and a scratch request spec gave the answers the next step specifies: own class 201, other class 400, cohort scope 400, `report-server` audience 500, no `researcher=true` 500, `jwt/portal` 500, legacy HS256 for the other class 201.

**Specs** (`signed_jwt_spec.rb`, `portal_signing_key_spec.rb`):
- mints RS256 with `kid: 'test-key'`, the given `aud`, `iss`, `uid`, `iat`, `exp` and no `alg` claim; refuses an unknown audience; the HS256 token is byte-for-byte shaped as before (`alg` claim present, no `kid` header)
- decode accepts the expected `aud`; refuses a wrong `aud`, a missing `aud` and an `aud` array containing the expected value
- decode with `aud: nil` refuses any token carrying a `kid`, and still accepts a legacy HS256 token
- **alg confusion**: an HS256 token carrying `kid: 'test-key'` signed with the public key's PEM as the secret is refused; so is the same token without a `kid`
- **unknown `kid`** refused; token with no `kid` signed RS256 refused (it routes to the HS256 branch and fails `IncorrectAlgorithm`)
- **another environment's key**: a token signed by a freshly generated key under `kid: 'test-key'` is refused
- `alg: none`, with and without a `kid`, refused
- a token signed by a previous key verifies when `PORTAL_PREVIOUS_VERIFY_KEYS` names its `kid`, and not otherwise
- `PortalSigningKey.configured?` false when either variable is blank; a `\n`-escaped PEM parses; a malformed PEM or JSON raises `SignedJwt::Error`
- an expired RS256 token raises `JWT::ExpiredSignature`, matching the HS256 path's contract with its callers

`jwt_bearer_token_authenticatable_spec.rb` and `api_controller_spec.rb`: an RS256 token of each of the three audiences is refused by the strategy and by `check_for_auth_token(params)`; `check_for_auth_token(params, aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)` accepts a launch token and sets `Current.token_scope_kind` and `token_scope_id`, and still refuses the two service audiences.

---

### Name the researcher gate once: `User#can_be_researcher_for_clazz?`

**Summary**: Extracts the inline check in `jwt_controller#firebase` into `User`, so the launch action, the Research Classes row and the Firebase mint apply one definition. Behavior-preserving. Covers R13.

**Files affected**:
- `rails/app/models/user.rb` — new method beside `is_project_admin_for_clazz?`
- `rails/app/controllers/api/v1/jwt_controller.rb` — the researcher branch calls it
- `rails/spec/models/user_spec.rb` — four cases

**Estimated diff size**: ~60 lines

```ruby
  # The gate on reading a class's data as a researcher: a project researcher (whose grant
  # has not expired) or project admin reaching the class through one of its teachers'
  # cohorts, or a site admin. It decides which classes a researcher Firebase token may be
  # minted for and which classes the Researcher Dashboard may open.
  def can_be_researcher_for_clazz?(clazz)
    is_researcher_for_clazz?(clazz) || is_project_admin_for_clazz?(clazz) || has_role?('admin')
  end
```

`jwt_controller.rb`, replacing lines 230–231:

```ruby
      if !user.can_be_researcher_for_clazz?(clazz)
        raise StandardError, "You do not have access to the requested class_hash as a researcher"
      end
```

**Specs**: true for a project researcher of the class's cohort, a project admin of it and a site admin; false for a researcher of an unrelated project and for a researcher whose grant has expired. The existing `jwt_controller_spec` researcher cases pass unchanged.

---

### Accept the launch token at `jwt/firebase` for its own class only

**Summary**: `GET /api/v1/jwt/firebase?researcher=true` accepts an `aud: researcher-dashboard` bearer, and when the bearer carries a scope it must name the requested class. Every other branch of `firebase`, and `portal`, still accept no RS256 token. Callers with an unscoped bearer see no change. Covers R11a, R19, R20.

**Files affected**:
- `rails/app/controllers/api/v1/jwt_controller.rb` — `firebase` passes the audience on the researcher branch and checks the scope
- `rails/spec/controllers/api/v1/jwt_controller_spec.rb` — a `context "with a researcher-dashboard launch token"` block

**Estimated diff size**: ~140 lines

```ruby
  def firebase
    # A launch token reaches only the researcher mint, and only for the class it was
    # launched for; it opens no other branch here and nothing in #portal.
    researcher = params[:researcher] == "true"
    user, learner, teacher = handle_initial_auth(aud: researcher ? SignedJwt::AUD_RESEARCHER_DASHBOARD : nil)
    ...
    if researcher
      ...
      clazz = Portal::Clazz.find_by_class_hash(params[:class_hash])
      if !clazz
        raise StandardError, "A class with the requested class_hash does not exist"
      end
      check_token_scope(clazz)

      if !user.can_be_researcher_for_clazz?(clazz)
      ...

  private

  # The scope is what the launch was for, not what it permits: the researcher check
  # above still runs on the matching class, because a token outlives a permission change.
  def check_token_scope(clazz)
    return if Current.token_scope_kind.nil? && Current.token_scope_id.nil?
    if Current.token_scope_kind != 'class'
      raise StandardError, "This token's scope kind (#{Current.token_scope_kind.inspect}) cannot mint a class token"
    end
    if Current.token_scope_id != clazz.id
      raise StandardError, "The requested class_hash is not the class this token was issued for"
    end
  end
```

`check_token_scope` lives in the existing private section; the scope comparison is integer to integer because R15 mints `scope_id` as an integer.

**Specs** (a researcher of two classes, A and B; a launch token minted for A):
- class A's hash: 201, token carries `user_type: "researcher"` and A's `class_hash`
- class B's hash: 400 with the not-this-class message, although the user passes the researcher check for B
- a token with `scope_kind: "cohort"`: 400
- a token scoped to A for a user whose researcher grant on A has since expired: 400 from the researcher check (scope is not authorization)
- the launch token without `researcher=true`: refused (500 from `SignedJwt::Error`, the endpoint's existing answer to a token it cannot decode)
- the launch token at `POST /api/v1/jwt/portal`: refused the same way, and no token is minted
- `report-server` and `report-service-functions` tokens with `researcher=true`: refused
- a legacy HS256 bearer and an AccessGrant bearer asking for B with `researcher=true`: 201, as today

---

### Launch the dashboard from the Research Classes table

**Summary**: Adds the `ResearcherDashboard` module (enabled when both the URL and the signing key are configured), the launch action, its route, the row field and the table link. The action mints a two-hour `researcher-dashboard` token scoped to the class and redirects with `token` as the only parameter it adds. Covers R6, R9, R14 to R18.

**Files affected**:
- `rails/app/services/researcher_dashboard.rb` — new
- `rails/app/controllers/portal/clazzes_controller.rb` — `researcher_dashboard` action
- `rails/config/routes.rb` — `get :researcher_dashboard` in the portal `clazzes` member block, beside `get :current_clazz`
- `rails/app/controllers/api/v1/research_classes_controller.rb` — `researcher_dashboard_url` on each row where it applies
- `rails/react-components/src/library/components/researcher-classes-form/table.tsx` — the link
- `rails/spec/services/researcher_dashboard_spec.rb` (new), `rails/spec/controllers/portal/clazzes_controller_spec.rb` (a `describe "GET researcher_dashboard"` block, signing in with Devise's `sign_in` as the file's other blocks do), `rails/spec/controllers/api/v1/research_classes_controller_spec.rb`

**Estimated diff size**: ~260 lines

`rails/app/services/researcher_dashboard.rb`:

```ruby
# Where this deployment's Researcher Dashboard app lives, whether it is on, and the URL
# that launches it into a scope.
#
# On only when there is somewhere to send a researcher and a key to sign the launch
# with, so an environment missing either offers no link rather than one that fails.
# Gated on configuration rather than a feature flag, as the researcher report links
# already are (REPORT_SERVER_REPORTS_URL in navigation_helper.rb).
module ResearcherDashboard
  # Long enough for a session's rigse calls; the app's Firebase sessions outlive it, and
  # an expired one sends the researcher back to the portal to relaunch. Matches the class
  # dashboard's ExternalReport::ReportTokenValidFor.
  LAUNCH_TOKEN_TTL = 2.hours.to_i

  def self.url
    ENV['RESEARCHER_DASHBOARD_URL'].presence
  end

  def self.enabled?
    url.present? && PortalSigningKey.configured?
  end

  # Everything the launch used to put in the query is a signed claim, so token is the
  # only parameter added. Role flags never go in: this token rides in a URL.
  def self.launch_url(user:, clazz:)
    token = SignedJwt.create_portal_token(
      user,
      { user_type: 'researcher', scope_kind: 'class', scope_id: clazz.id },
      LAUNCH_TOKEN_TTL,
      aud: SignedJwt::AUD_RESEARCHER_DASHBOARD
    )
    uri = URI.parse(url)
    uri.query = Rack::Utils.build_query(Rack::Utils.parse_query(uri.query).merge('token' => token))
    uri.to_s
  end
end
```

`rails/app/controllers/portal/clazzes_controller.rb`, after `external_report`:

```ruby
  # Sends a researcher to the dashboard for this class, as external_report sends them to a
  # class report: authorize, mint, redirect. The researcher gate rather than the class
  # policy, because opening someone else's class is what this is for.
  def researcher_dashboard
    return head(:not_found) unless ResearcherDashboard.enabled?

    portal_clazz = Portal::Clazz.find(params[:id])
    unless current_visitor.can_be_researcher_for_clazz?(portal_clazz)
      raise Pundit::NotAuthorizedError, 'not a researcher for this class'
    end

    redirect_to ResearcherDashboard.launch_url(user: current_visitor, clazz: portal_clazz), allow_other_host: true
  end
```

`research_classes_controller.rb#classes_mapping` builds each row as today and adds the key only when it applies, so rows without it are unchanged and the existing exact-match expectations in `research_classes_controller_spec.rb` (lines 120, 229, 268, 278) need no edit:

```ruby
    classes_query.map do |c|
      row = { ...existing keys unchanged... }
      dashboard_url = researcher_dashboard_url_for(c)
      row[:researcher_dashboard_url] = dashboard_url if dashboard_url
      row
    end
  end

  # The same gate the launch action applies, one request earlier, so the table offers a
  # link only where following it would work.
  def researcher_dashboard_url_for(clazz)
    return nil unless ResearcherDashboard.enabled?
    return nil unless current_user.can_be_researcher_for_clazz?(clazz)
    researcher_dashboard_portal_clazz_url(clazz.id)
  end
```

This costs up to three count queries per row, the same order as the existing per-row `policy(c).roster?` the comment above it already accepts.

`table.tsx`, after the roster link:

```tsx
                    { c.researcher_dashboard_url &&
                      <><br /><a href={c.researcher_dashboard_url} target="_blank" rel="noreferrer">Researcher Dashboard</a></>
                    }
```

**Specs**:
- `ResearcherDashboard.enabled?` false with either the URL or the key missing
- `launch_url` keeps the configured URL's own query parameters, adds exactly `token`, and the token decodes with `aud: researcher-dashboard` to `iss`, `uid`, `user_type: "researcher"`, `scope_kind: "class"`, `scope_id` (an integer), an `exp` two hours out, a `kid` header, and **no** `is_admin`, `is_project_admin`, `is_project_researcher`, `admin` or `project_admins`
- controller specs: a researcher is redirected (302) to the dashboard with one `token`; a non-researcher gets the not-authorized response and no redirect to the dashboard; an anonymous visitor is sent to sign in; with the dashboard disabled the action answers 404; with an unknown class id, 404
- the redirect's query parameter count is one when `RESEARCHER_DASHBOARD_URL` carries none (the Done-when "a launch URL carries one parameter")
- `research_classes`: the row carries `researcher_dashboard_url` for a researcher of the class when enabled, and has no such key when disabled or for a class the user fails the gate on

The React change is one conditional link beside an existing one of the same shape; `researcher-classes-form` has no Jest tests today, and `npm run build` in `react-components` is the check.

---

### Mint the two service assertions

**Summary**: Adds the `report-server` and `report-service-functions` token builders RIGSE-368 will call and REPORT-141 will verify, with nothing on master sending them yet. Covers R7.

**Files affected**:
- `rails/app/services/researcher_dashboard/assertions.rb` — new
- `rails/spec/services/researcher_dashboard/assertions_spec.rb` — new

**Estimated diff size**: ~140 lines

```ruby
module ResearcherDashboard
  # The two short-lived assertions rigse signs for other services. Both travel service to
  # service and never reach a browser, which is why the role flags are allowed here and
  # never in the launch token. The function relays the report-server one without being
  # able to re-aim it, since it holds no signing key.
  module Assertions
    # Long enough to survive a cold function start and the one call that follows it.
    TTL = 120

    # Exchanged at report-server for the researcher's own API token. Carries what
    # report-server's user row requires (its PortalUserInfo), because its changeset
    # validates every portal field and names the Athena workgroup from the email. The jti
    # lets report-server refuse a replay inside the window.
    def self.report_server(user:, clazz:)
      SignedJwt.create_portal_token(user, {
        user_type: 'researcher',
        scope_kind: 'class',
        scope_id: clazz.id,
        jti: SecureRandom.uuid,
        portal_user_id: user.id,
        portal_server: URI.parse(APP_CONFIG[:site_url]).host,
        login: user.login,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        is_admin: user.has_role?('admin'),
        is_project_admin: user.admin_for_projects.any?,
        is_project_researcher: user.researcher_for_projects.any?
      }, TTL, aud: SignedJwt::AUD_REPORT_SERVER)
    end

    # Presented to the report-service function to queue work, in place of its shared bearer.
    def self.report_service_functions(user:)
      SignedJwt.create_portal_token(user, {}, TTL, aud: SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS)
    end
  end
end
```

`is_project_researcher` uses `researcher_for_projects`, which excludes expired grants, so a researcher whose grant has lapsed is not reported as one; report-server's own `get_user_info` query does not filter expiry, and the portal's answer is the fresher one.

**Specs**: each decodes with its own audience and is refused with the other two; `report-server` carries the scope, the identity fields, the flags computed from the database (a site admin, a project admin, a researcher, an expired researcher), a UUID `jti` that differs per call, and `exp - iat == 120`; `report-service-functions` carries exactly `iss`, `iat`, `exp`, `uid`, `aud` and no scope, flags or identity fields.

---

### Configure the key, the dashboard URL, and how an operator obtains the public key

**Summary**: Wires the new variables through local Docker and both ECS task definitions, adds a rake task that generates a keypair and one that prints the current public key and `kid` for report-server and the function, and documents the rotation. Covers R5, R21, R22.

**Files affected**:
- `docker-compose.yml` — `RESEARCHER_DASHBOARD_URL`, `PORTAL_SIGNING_KEY`, `PORTAL_SIGNING_KEY_ID`, `PORTAL_PREVIOUS_VERIFY_KEYS` in the app service, no defaults for the key
- `configs/cloudformation/stack_template.yml` — four parameters (`PortalSigningKey` with `NoEcho: true`, all defaulting to empty) and the four environment entries in both `AppTaskDefinition` and `WorkerTaskDefinition`
- `rails/lib/tasks/portal_signing_key.rake` — new
- `README.md` — a "Researcher Dashboard" section

**Estimated diff size**: ~150 lines

```ruby
namespace :portal_signing_key do
  # Prints a new keypair in the shape the environment takes. Run once per environment;
  # staging and production must never share the output.
  #   rake portal_signing_key:generate KID=production-2026-09
  desc 'Generate an RS256 keypair for PORTAL_SIGNING_KEY'
  task :generate do
    kid = ENV.fetch('KID') { abort 'Set KID, e.g. KID=staging-2026-09' }
    key = OpenSSL::PKey::RSA.generate(2048)
    puts "PORTAL_SIGNING_KEY_ID=#{kid}"
    puts "PORTAL_SIGNING_KEY=#{key.to_pem.gsub("\n", '\n')}"
    puts
    puts "Public key for report-server and the report-service function, under kid #{kid}:"
    puts key.public_key.to_pem
  end

  # What report-server and the function need to verify this environment's tokens.
  desc 'Print the configured public key and kid'
  task public: :environment do
    abort 'PORTAL_SIGNING_KEY and PORTAL_SIGNING_KEY_ID are not both set' unless PortalSigningKey.configured?
    puts "kid: #{PortalSigningKey.kid}"
    puts PortalSigningKey.private_key.public_key.to_pem
  end
end
```

The README section states: what the three variables are; that the private key is set only on rigse and the public key (from `rake portal_signing_key:public`) is configured by value in report-server and the report-service function under its `kid`; that staging and production each generate their own; that there is no JWKS endpoint by design; and that a rotation is two deploys (add the new public key to the verifiers and move the old key's public half into `PORTAL_PREVIOUS_VERIFY_KEYS` while switching rigse to the new key, then drop the old one once its tokens have expired, which for the launch token is two hours). `PORTAL_SERVICE_SECRET` is not introduced anywhere; the step's check is `git grep PORTAL_SERVICE_SECRET` returning nothing.

**Getting it onto a stack.** The release skill updates the stack with `--use-previous-template` (`.claude/skills/release-portal/SKILL.md`, step 6), so releasing this code does not add the four parameters or their environment entries to a running stack; the dashboard stays disabled there, which is safe. Turning it on is a separate, deliberate template update per environment, with that environment's own key and URL supplied as parameter values, and the README section says so. Later releases carry the values forward, since the skill passes every existing parameter with `UsePreviousValue=true`, which also keeps the `NoEcho` key intact.

**Specs**: none for configuration. A throwaway check before commit: `rake portal_signing_key:generate KID=x` output pasted into the environment makes `rake portal_signing_key:public` print the matching public key.

---

**`REPORT_SERVICE_BEARER_TOKEN`.** No step changes it (R23): this story adds no use of it and removes none, and it stays the credential for `get_feedback_metadata`.

## Open Questions

<!-- Implementation-focused questions only. Requirements questions go in requirements.md. -->

### RESOLVED: Judgment call: route by the `kid` header rather than by the header `alg`
**Context**: Both are safe when each branch pins its own algorithm and key (requirements Technical Notes).
**Options considered**:
- A) `kid` present means RS256 against the `kid`'s key; absent means legacy HS256.
- B) Header `alg` chooses the branch.

**Decision**: A. It is the property the story names ("the key is chosen by `kid`"), a legacy HS256 token never carries a `kid`, and the stage 4 dispatch probe ran all eight attack and legacy cases against exactly this routing. B reads the one header field the story says must never choose the key, even if each branch then pins it.

### RESOLVED: Judgment call: extend `create_portal_token` and `decode_portal_token` rather than add parallel RS256 methods
**Options considered**:
- A) One mint and one decode, the audience deciding the algorithm, with `aud:` a required keyword on decode.
- B) New `create_rs256_token` / `decode_rs256_token` beside the untouched HS256 ones.

**Decision**: A. The story says `create_portal_token` gains `aud` and `decode_portal_token` takes the expected audience, and a required keyword is what makes "every call site names the one it accepts" enforced by Ruby rather than by review. B would leave the two existing decode sites unaware of RS256 tokens, which is the gap that makes any rigse-signed token a bearer for the whole API.

### RESOLVED: Judgment call: the scope travels in `Current`, not in `check_for_auth_token`'s return value
**Options considered**:
- A) `Current.token_scope_kind` / `token_scope_id`, beside the existing `minted_via_oidc_client_id`.
- B) Return a third element from `check_for_auth_token` and `handle_initial_auth`.

**Decision**: A. `Current` already carries per-request token facts for exactly this pair of decode paths (RIGSE-352's marker), resets per request, and leaves the two-element return every existing caller destructures unchanged.

## Self-Review

Roles: Security Engineer, Senior Rails Engineer, reviewer of the resulting commits, the engineer running the tests, the operator deploying it. Steps 1 and 3 were built as throwaway code and run (see step 1); other claims were checked against the repository. Candidates that did not survive were dropped: step independence (each step's code references only constants and methods an earlier step adds, and the throwaway build of steps 1 and 3 together passed 225 existing examples); thread safety of the parsed-key memo in `PortalSigningKey` (a benign race under MRI that at worst parses a key twice); and the 500 a refused RS256 token gets from `jwt_controller`, which is that endpoint's existing answer to any token it cannot decode (`rescue_from SignedJwt::Error, with: :error_500`) and so is not a change this story introduces.

### Senior Rails Engineer

#### RESOLVED: The HS256 payload's key order would have changed
The first draft built the payload without `alg` and appended it for HS256, moving it from first to last, while the specs promised legacy tokens byte-for-byte unchanged. Nothing verifies key order, but the promise was false and a spec asserting it would have failed. Fixed: the HS256 payload starts with `alg` as today.

### Engineer running the tests

#### RESOLVED: The test keypair line fails at spec load without `require "openssl"`
`spec_helper.rb` sets its environment before Rails loads. Applied as throwaway code, every spec file failed at load with `NameError` on `OpenSSL`. Fixed in step 1.

#### RESOLVED: The launch action's specs were planned as request specs, which have no sign-in helper here
`spec/requests` holds one skipped placeholder, and `AuthenticatedTestHelper#login_as` writes `@request.session`, which is controller-spec only. `spec/controllers/portal/clazzes_controller_spec.rb` already signs users in with Devise's `sign_in` for this controller. Fixed: step 4 puts the launch specs there.

### Operator

#### RESOLVED: A normal release does not add the new parameters to a stack
The release skill runs `update-stack --use-previous-template` (`release-portal/SKILL.md`, step 6), so the four parameters and their environment entries exist on a stack only after a deliberate template update. Without saying so, step 6 read as if releasing the code configured the dashboard. Fixed: step 6 and the README section state that enabling it per environment is a template update with that environment's values, after which releases carry them forward with `UsePreviousValue=true`.

### Security Engineer

No defect found. Checked and confirmed as designed: an RS256 token is refused by the Devise strategy, which matters beyond the audience rule because `spec/requests/service_minted_session_gap_spec.rb` records that a token Devise accepts is serialized into the Rails session (the D10 gap), so accepting the launch token there would turn a two-hour scoped credential into an unscoped session.
