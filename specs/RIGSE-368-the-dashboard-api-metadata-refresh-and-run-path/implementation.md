# Implementation Plan: The dashboard API: scope metadata, the profile refresh and the run path

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-368
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

Six steps, each one commit, in dependency order: the scope facts and the runner tokens first, since every endpoint uses them, then the three endpoints in the order the app calls them, then configuration. The plan builds on RIGSE-367's implementation, which must land first: `SignedJwt::AUD_*`, `decode_portal_token(token, aud:)`, `check_for_auth_token(params, aud:)` setting `Current.token_scope_*`, `User#can_be_researcher_for_clazz?`, `ResearcherDashboard.enabled?` and `ResearcherDashboard::Assertions`.

Every step was built as throwaway code on top of RIGSE-367's primitives (applied from its spec) and run in the test database before being written up; the code below is what ran, and the results are in each step's "Checked" note.

### Describe a class scope: its assignments, fingerprint, teachers, cohorts and projects

**Summary**: Adds `ResearcherDashboard::Scope`, which computes everything rigse says about a class scope from its own tables, and `ResearcherDashboard::Refusal`, the one error type the dashboard services raise. No endpoint uses them yet. Covers R8 to R12 and R14.

**Files affected**:
- `rails/app/services/researcher_dashboard/refusal.rb` — new
- `rails/app/services/researcher_dashboard/scope.rb` — new
- `rails/spec/services/researcher_dashboard/scope_spec.rb` — new

**Estimated diff size**: ~260 lines

`rails/app/services/researcher_dashboard/refusal.rb`:

```ruby
module ResearcherDashboard
  # A refusal with the status and message the app should see. Services raise it and the
  # controller renders it through API::APIController#error, so every dashboard failure,
  # rigse's own or one passed through from report-server or the function, has one shape.
  class Refusal < StandardError
    attr_reader :status, :details

    def initialize(status, message, details = nil)
      super(message)
      @status = status
      @details = details
    end
  end
end
```

`rails/app/services/researcher_dashboard/scope.rb`:

```ruby
require 'digest'

module ResearcherDashboard
  # What rigse knows about a class scope, computed from its own tables: the facts the
  # metadata endpoint returns, the assignment list the run path hands the VM, and the URL
  # list the profile refresh hands the deriver. One object computes all three, so the
  # fingerprint the app compares and the fingerprint a refresh records cannot disagree.
  class Scope
    FINGERPRINT_VERSION = 'v1'.freeze
    # REPORT-142's /derive-profile limits. A request over them is refused there, so it is
    # refused here instead, with a reason, before anything is sent.
    DERIVE_MAX_URLS = 500
    DERIVE_MAX_URL_LENGTH = 2048
    DERIVE_MAX_BODY_BYTES = 256 * 1024

    attr_reader :clazz

    def initialize(clazz)
      @clazz = clazz
    end

    # One entry per offering of an external activity, in the class's own order. The URL is
    # the stored column, never ExternalActivity#url, which re-serializes it (lowercasing the
    # scheme, dropping a default port). Offerings of any other runnable_type are skipped:
    # ExternalActivity is the only runnable left, and loading a runnable whose model is gone
    # raises NameError. Inactive offerings are included, since their student data exists.
    def assignments
      @assignments ||= clazz.offerings
        .where(runnable_type: 'ExternalActivity')
        .order(:id)
        .includes(runnable: :tool)
        .filter_map do |offering|
          activity = offering.runnable
          next unless activity
          {
            offering_id: offering.id,
            runnable_id: activity.id,
            name: activity.name,
            url: activity.read_attribute(:url),
            # For display only. Nothing matches on it: the URL says what the thing is.
            tool: activity.tool&.name
          }
        end
    end

    # What the VM writes into scope.json. No tool: section 10 keeps it out of the VM.
    def run_assignments
      assignments.map { |a| a.except(:tool) }
    end

    # Changes when an offering is added or removed or its URL changes, and only then. JSON
    # rather than a joined string so no URL can imitate a separator; versioned so a later
    # shape forces one refresh everywhere rather than comparing unlike values.
    def fingerprint
      pairs = assignments.map { |a| [a[:offering_id], a[:url]] }.sort_by(&:first)
      "#{FINGERPRINT_VERSION}:#{Digest::SHA256.hexdigest(JSON.generate(pairs))}"
    end

    # The body of POST /derive-profile. rigse supplies the list and does nothing else with
    # it: no fetching, parsing or normalizing, which is the deriver's job and what keeps it
    # from taking a URL from anyone but rigse. A URL too long for the deriver is left out
    # rather than denying the class a profile; a list too large for it is refused whole,
    # since a truncated profile would silently hide packages.
    def derive_profile_body
      urls = assignments.map { |a| a[:url] }
        .select { |url| url.present? && url.length <= DERIVE_MAX_URL_LENGTH }
        .uniq.sort
      if urls.size > DERIVE_MAX_URLS
        raise Refusal.new(422, "This class has #{urls.size} distinct assignment URLs, more than the #{DERIVE_MAX_URLS} a profile can be derived from")
      end
      body = { class_hash: clazz.class_hash, assignment_fingerprint: fingerprint, assignment_urls: urls }
      # Bytes rather than characters: never smaller than the function's character count.
      if JSON.generate(body).bytesize > DERIVE_MAX_BODY_BYTES
        raise Refusal.new(422, "This class's assignment URLs exceed the #{DERIVE_MAX_BODY_BYTES / 1024} KiB a profile can be derived from")
      end
      body
    end

    def teachers
      clazz.teachers.includes(:user).order(:id).map do |teacher|
        { id: teacher.user_id, name: "#{teacher.user.first_name} #{teacher.user.last_name}".strip }
      end
    end

    # The cohorts of the class's teachers, through the same join is_researcher_for_clazz?
    # uses, so "the projects this class belongs to" means what the researcher gate means.
    def cohorts
      @cohorts ||= Admin::Cohort
        .joins("INNER JOIN admin_cohort_items __aci ON __aci.admin_cohort_id = admin_cohorts.id AND __aci.item_type = 'Portal::Teacher'")
        .joins("INNER JOIN portal_teacher_clazzes __ptc ON __ptc.teacher_id = __aci.item_id")
        .where("__ptc.clazz_id = ?", clazz.id)
        .distinct
        .order(:id)
        .to_a
    end

    def project_ids
      cohorts.map(&:project_id).compact.uniq.sort
    end
  end
end
```

`.order(:id)` follows the association's own `order :position`, so offerings sharing a position (the column defaults to 0) still come back in a stable order. `filter_map` skips an offering whose external activity row is gone, which `dependent: :destroy` should prevent but legacy data may not. The external activity table is `utf8` (three-byte), so a URL holds no character outside the Basic Multilingual Plane and Ruby's `length` equals the JavaScript length REPORT-142 checks.

**Specs** (`scope_spec.rb`, a class with a teacher in a cohort of a project):
- `assignments`: one entry per external-activity offering, in position order, with the stored URL exactly (`HTTPS://host:443/...` comes back unchanged, where `ExternalActivity#url` would lowercase it and drop the port), the tool's `name`, and `tool: nil` for an activity with no tool; an inactive offering is included; an offering whose `runnable_type` is `Investigation` is skipped without raising; an empty URL and a nil name are returned as they are
- `run_assignments` is `assignments` without `tool`
- `fingerprint`: `v1:` plus 64 hex characters; identical on recomputation; different after an offering is added, after a second offering of the same activity is added, after the activity's URL changes, and after an offering is removed
- `derive_profile_body`: the class hash, the same fingerprint as `fingerprint`, distinct non-empty URLs sorted; a URL of 2,049 characters is left out while the fingerprint still covers it; 501 distinct URLs raise a 422 `Refusal`; URLs summing past 256 KiB raise a 422 `Refusal`
- `teachers`, `cohorts` (distinct, including cohorts of a second teacher) and `project_ids` (sorted, no nil for a cohort without a project)

**Checked.** The metadata endpoint built on this (step 3) answered, for a class with one Activity Player offering and one offering whose `runnable_type` was set to `Investigation`: one assignment, `url` `"HTTPS://ap.example:443/?activity=..."` as stored, `tool` `"Activity Player"`, the teacher, the cohort, `project_ids` `[52]`, and a 67-character fingerprint. A class with 501 generated offerings plus one other was refused 422 with no outbound request.

---

### Share the Firebase identity claims and mint runner tokens

**Summary**: Moves the identity every portal Firebase token carries out of `jwt_controller` into `FirebaseTokenClaims`, so the browser's researcher token and the runner's tokens name one Firebase principal, and adds `ResearcherDashboard::RunnerTokens`. The `jwt_controller` change is behavior-preserving. Covers R19 and R24.

**Files affected**:
- `rails/lib/firebase_token_claims.rb` — new
- `rails/app/controllers/api/v1/jwt_controller.rb` — `firebase` uses `FirebaseTokenClaims`; the private `jwt_user_id` is deleted
- `rails/app/services/researcher_dashboard/runner_tokens.rb` — new
- `rails/spec/libs/firebase_token_claims_spec.rb`, `rails/spec/services/researcher_dashboard/runner_tokens_spec.rb` — new

**Estimated diff size**: ~170 lines

`rails/lib/firebase_token_claims.rb`:

```ruby
require 'digest/md5'

# The identity every Firebase custom token the portal mints for a user carries. The
# browser's tokens (API::V1::JwtController#firebase) and the Researcher Dashboard runner's
# (ResearcherDashboard::RunnerTokens) must name the same Firebase principal, since the
# rules in both projects key on uid, platform_id and platform_user_id.
module FirebaseTokenClaims
  # A Firebase uid is 1 to 36 characters and unique across portals; MD5 of the
  # portal-qualified user URL is 32.
  def self.uid(user)
    Digest::MD5.hexdigest(user_id(user))
  end

  def self.user_id(user)
    APP_CONFIG[:site_url].sub(/\/$/, '') + Rails.application.routes.url_helpers.polymorphic_path(user)
  end

  # Firebase rules read these from the "claims" sub-object.
  def self.identity(user)
    { platform_id: APP_CONFIG[:site_url], platform_user_id: user.id, user_id: user_id(user) }
  end
end
```

`jwt_controller.rb#firebase`:

```ruby
    # before
    sub_claims = {
      platform_id: APP_CONFIG[:site_url],
      platform_user_id: user.id,
      user_id: jwt_user_id(user)
    }
    ...
    uid = Digest::MD5.hexdigest(jwt_user_id(user))

    # after
    sub_claims = FirebaseTokenClaims.identity(user)
    ...
    uid = FirebaseTokenClaims.uid(user)
```

`jwt_user_id` (`jwt_controller.rb:140-143`) has no other caller and is deleted.

`rails/app/services/researcher_dashboard/runner_tokens.rb`:

```ruby
module ResearcherDashboard
  # The Firebase custom tokens a researcher's runner signs in with. Both carry
  # researcher_dashboard_runner, which report-service's rules require for the runner's
  # writes and CLUE's rules use to deny them; neither is ever returned to a browser.
  #
  # The session token names no class and writes the researcher's runner document in the
  # report-service project. A class token carries the class_hash the class-scoped rules
  # key on, one per Firebase project, since a custom token is signed by one project's
  # service account and cannot be exchanged in another.
  #
  # The caller authorizes: nothing here checks can_be_researcher_for_clazz?.
  module RunnerTokens
    # The longest a Firebase custom token may live.
    TTL = 3600

    def self.session_token(user:, firebase_app:)
      mint(user, firebase_app, {})
    end

    def self.class_token(user:, clazz:, firebase_app:)
      mint(user, firebase_app, { class_hash: clazz.class_hash })
    end

    def self.mint(user, firebase_app, extra)
      claims = FirebaseTokenClaims.identity(user)
        .merge(user_type: 'researcher', researcher_dashboard_runner: true)
        .merge(extra)
      SignedJwt.create_firebase_token(FirebaseTokenClaims.uid(user), firebase_app, TTL, { claims: claims })
    end
    private_class_method :mint
  end
end
```

**Specs**: `FirebaseTokenClaims.user_id` is the site URL without its trailing slash plus `/users/<id>`, `uid` its MD5, `identity` the three claims. A session token decodes (`SignedJwt.decode_firebase_token`) with the identity claims, `user_type: "researcher"`, `researcher_dashboard_runner: true`, no `class_hash`, and `exp - iat == 3600`; a class token adds the class's `class_hash`; both use `FirebaseTokenClaims.uid`; an unknown FirebaseApp raises `SignedJwt::Error`. The existing `jwt_controller_spec` passes unchanged.

**Checked.** Inside a controller, the deleted `jwt_user_id(user)` and `FirebaseTokenClaims.user_id(user)` returned the same string (`http://app.portal.docker/users/1010`). The run path built on this minted a class token for `collaborative-learning-staging` decoding to `{platform_id, platform_user_id, user_id, user_type: "researcher", researcher_dashboard_runner: true, class_hash}` and a session token with the same claims and no `class_hash`. With `jwt_user_id` deleted and `firebase` using `FirebaseTokenClaims`, `jwt_controller_spec`, `jwt_controller_guard_spec` and `api_controller_spec` passed (72 examples, 0 failures).

---

### Serve the scope's metadata to a launch token

**Summary**: Adds `API::V1::ResearcherDashboardController` with the authorization every action shares and the metadata action, its route, and the CORS entry. Covers R1 to R7.

**Files affected**:
- `rails/app/controllers/api/v1/researcher_dashboard_controller.rb` — new, with `clazz` only
- `rails/config/routes.rb` — `namespace :researcher_dashboard` with the `classes/:id` route, above `namespace :jwt`
- `rails/config/application.rb` — `resource '/api/v1/researcher_dashboard/*', :headers => :any, :methods => [:get, :post]` beside the `jwt/*` entry
- `rails/spec/controllers/api/v1/researcher_dashboard_controller_spec.rb` — new

**Estimated diff size**: ~300 lines

The controller as it stands after the last endpoint step; this step adds it without `refresh_profile`, `run_package`, their `rescue_from` for `Settings::NotConfigured`, and their routes:

```ruby
# The three calls the Researcher Dashboard app makes with its launch token: the scope's
# metadata, a refresh of its authored URL profile, and the run path.
#
# Only a launch token opens them, because only a launch token carries the scope they act
# on; a session, an HS256 portal token or an AccessGrant authenticates but names no scope.
# The scope says what the launch was for and never authorizes on its own, so the researcher
# gate runs on every call, before anything is read, minted or sent.
class API::V1::ResearcherDashboardController < API::APIController
  # The run body is read as exactly what was sent (RunRequest), so Rails' copy of it under
  # the controller's name would only be a second, looser reading.
  wrap_parameters false

  before_action :require_dashboard_enabled
  before_action :authorize_scope
  before_action :require_path_matches_scope, only: [:clazz, :refresh_profile]

  rescue_from ResearcherDashboard::Refusal do |e|
    error(e.message, e.status, e.details)
  end
  rescue_from ResearcherDashboard::Settings::NotConfigured do |e|
    error("The Researcher Dashboard is not fully configured: #{e.message}", 503)
  end
  rescue_from ActionDispatch::Http::Parameters::ParseError do
    error('The body must be a JSON object', 400)
  end

  # GET /api/v1/researcher_dashboard/classes/:id
  def clazz
    scope = ResearcherDashboard::Scope.new(@clazz)
    render json: {
      id: @clazz.id,
      name: @clazz.name,
      class_hash: @clazz.class_hash,
      # Whose dashboard this is: the app keys its runner and result listeners by it.
      platform_user_id: @user.id,
      teachers: scope.teachers,
      cohorts: scope.cohorts.map { |c| { id: c.id, name: c.name } },
      project_ids: scope.project_ids,
      assignment_fingerprint: scope.fingerprint,
      assignments: scope.assignments
    }
  end

  # POST /api/v1/researcher_dashboard/classes/:id/refresh_profile
  def refresh_profile
    render status: 202, json: ResearcherDashboard::ProfileRefresh.call(user: @user, clazz: @clazz)
  end

  # POST /api/v1/researcher_dashboard/run_package
  def run_package
    packages = ResearcherDashboard::RunRequest.parse(request.raw_post)
    render status: 202, json: ResearcherDashboard::RunPackage.call(
      user: @user, clazz: @clazz, packages: packages, launch_token: @launch_token
    )
  end

  private

  def require_dashboard_enabled
    head :not_found unless ResearcherDashboard.enabled?
  end

  def authorize_scope
    begin
      @user, _role = check_for_auth_token(params, aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)
    rescue ActionDispatch::Http::Parameters::ParseError
      raise
    rescue StandardError => e
      # SignedJwt::Error, JWT::ExpiredSignature, and check_for_auth_token's own refusals.
      return error("Launch the Researcher Dashboard again from the portal (#{e.message})", 401)
    end
    if Current.token_scope_kind.nil? && Current.token_scope_id.nil?
      return error('This endpoint accepts only a Researcher Dashboard launch token', 401)
    end
    unless Current.token_scope_kind == 'class'
      return error("This token's scope kind (#{Current.token_scope_kind.inspect}) is not supported", 403)
    end
    @clazz = Portal::Clazz.find_by_id(Current.token_scope_id)
    return error('The class this token was issued for no longer exists', 404) unless @clazz
    unless @user.can_be_researcher_for_clazz?(@clazz)
      return error('You do not have access to this class as a researcher', 403)
    end
    # Forwarded unchanged to report-server's resolve, which applies its visibility rule to
    # the same researcher. Never logged and never returned.
    @launch_token = extract_bearer_token(request.headers['Authorization'])
  end

  def require_path_matches_scope
    unless Integer(params[:id], 10, exception: false) == @clazz.id
      error('The requested class is not the class this token was issued for', 403)
    end
  end
end
```

`rails/config/routes.rb`, inside `namespace :v1`, which sits in the `constraints :id => /\d+/` block:

```ruby
        # The Researcher Dashboard app's calls, all opened by its launch token. `to:` is
        # absolute because inside a namespace it resolves one level deeper.
        namespace :researcher_dashboard do
          get  'classes/:id', to: '/api/v1/researcher_dashboard#clazz', as: :clazz
          post 'classes/:id/refresh_profile', to: '/api/v1/researcher_dashboard#refresh_profile', as: :refresh_profile
          post :run_package, to: '/api/v1/researcher_dashboard#run_package'
        end
```

Notes on the controller:
- **Why `check_for_auth_token` alone is not enough.** It also accepts a session, an HS256 portal token and an AccessGrant, and none of them sets `Current.token_scope_*` (RIGSE-367 sets them only for a token carrying a `kid`). Requiring a scope is what makes R1 "launch token only".
- **The user is the one the token names.** The Devise strategy refuses every RS256 token, so `current_user` is nil here and `@user` comes from `check_for_auth_token`.
- **`wrap_parameters false`.** Under `config.load_defaults 7.0` Rails copies a JSON body under the controller's name; the run path reads the raw body itself (step 5).
- **`ParseError` is re-raised from the auth block** so a malformed JSON body is the `rescue_from`'s 400 rather than a 401.
- **A non-numeric `:id`** is the router's 404 (`rails routes -g researcher_dashboard` shows `:id=>/\d+/`); `require_path_matches_scope` compares integers.

**Harness.** `ResearcherDashboard.enabled?` and the settings read `ENV` on every call, and `spec_helper.rb` sets only RIGSE-367's signing key, so without `RESEARCHER_DASHBOARD_URL` every action answers 404. The controller and service specs set `RESEARCHER_DASHBOARD_URL` and the four R29 variables in an `around` hook that restores the previous values, so no other spec file sees them.

**Specs** (a researcher of class A through a project cohort; a launch token minted for A with `SignedJwt.create_portal_token(..., aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)`, sent as `request.headers['Authorization']`):
- 200 with exactly the R7 keys: `id`, `name`, `class_hash`, `platform_user_id` (the token's user), `teachers`, `cohorts`, `project_ids`, `assignment_fingerprint`, `assignments`; the body contains no `platform` key at any level
- 401: no bearer; an expired launch token; a legacy HS256 portal token for the same user; a Devise session signed in with `sign_in` and no bearer; `report-server` and `report-service-functions` tokens
- 403: a token scoped to class B requesting A; `scope_kind: "cohort"`; a user who fails `can_be_researcher_for_clazz?`; a researcher whose grant has expired since the token was minted
- 404: the scoped class deleted; the dashboard disabled (`RESEARCHER_DASHBOARD_URL` unset)
- a request spec (`spec/requests/researcher_dashboard_cors_spec.rb`): an `OPTIONS` preflight from another origin for `POST .../run_package` with `authorization,content-type` answers `Access-Control-Allow-Origin: *` and allows both headers

**Checked.** Built and run: with the refresh and run services, their routes and their `rescue_from` removed, the metadata action answered 200 on its own, so this step does not depend on the next two. Every case above gave the listed status (launch token 200 with `current_user` nil and an `Integer` `scope_id`; `classes/B` 403; cohort kind 403; `report-server` audience 401; HS256 and session-only 401; non-researcher 403; expired 401; dashboard disabled 404). The preflight answered 200 with `access-control-allow-origin: *`, `access-control-allow-methods: GET, POST` and `access-control-allow-headers: authorization,content-type`.

---

### Refresh the authored profile through the function

**Summary**: Adds the dashboard's settings reader, the one client every outbound call goes through, and `refresh_profile`. Covers R5 (the 503), R11 to R15, R26 to R28 for the refresh, the settings half of R29, and R30.

**Files affected**:
- `rails/app/services/researcher_dashboard/settings.rb` — new
- `rails/app/services/researcher_dashboard/upstream.rb` — new
- `rails/app/services/researcher_dashboard/profile_refresh.rb` — new
- `rails/app/controllers/api/v1/researcher_dashboard_controller.rb` — `refresh_profile`, `rescue_from Settings::NotConfigured`
- `rails/config/routes.rb` — the `refresh_profile` route
- `rails/spec/services/researcher_dashboard/upstream_spec.rb` — new; `researcher_dashboard_controller_spec.rb` — a `refresh_profile` block

**Estimated diff size**: ~300 lines

`rails/app/services/researcher_dashboard/settings.rb`:

```ruby
module ResearcherDashboard
  # Where the dashboard's server-to-server calls go and which Firebase projects its runner
  # tokens are minted in. Read per call rather than at boot, so the metadata endpoint works
  # in an environment that has not configured the run path, and a missing value is a 503
  # naming it rather than a failure somewhere downstream.
  module Settings
    class NotConfigured < StandardError; end

    # report-server's base URL, for the run path's catalog resolve.
    def self.report_server_url
      fetch('REPORT_SERVER_URL').chomp('/')
    end

    # report-service's researcherDashboard function, for /run-package and /derive-profile.
    # Not REPORT_SERVICE_URL, which is the shared-bearer api function feedback metadata uses.
    def self.function_url
      fetch('RESEARCHER_DASHBOARD_FUNCTION_URL').chomp('/')
    end

    # The FirebaseApp in report-service's project. Its name is the project id, which is
    # what the runner signs in to and what it looks its class token up by.
    def self.firebase_app
      fetch('RESEARCHER_DASHBOARD_FIREBASE_APP')
    end

    # The FirebaseApp in CLUE's project, for packages that declare clue_prepull. Deleted,
    # with the mint it feeds, once the runner reads CLUE through cc-data (RIGSE-369).
    def self.clue_firebase_app
      fetch('RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP')
    end

    def self.fetch(name)
      ENV[name].presence || raise(NotConfigured, "#{name} is not set")
    end
    private_class_method :fetch
  end
end
```

`rails/app/services/researcher_dashboard/upstream.rb`:

```ruby
module ResearcherDashboard
  # One call to report-server or the report-service function. Every call has its own open
  # and read timeouts, and a timeout or a connection failure becomes a Refusal rather than
  # an exception reaching Rails as a 500. Nothing here logs a request or response body,
  # because the run path's bodies carry runner tokens.
  module Upstream
    OPEN_TIMEOUT = 5
    REASON_MAX = 300
    NAMES = { report_server: 'report-server', function: 'report-service' }.freeze

    def self.get(upstream, url, query:, bearer:, read_timeout:)
      call(upstream) do
        HTTParty.get(url, query: query, headers: { 'Authorization' => "Bearer #{bearer}", 'Accept' => 'application/json' },
                     open_timeout: OPEN_TIMEOUT, read_timeout: read_timeout)
      end
    end

    def self.post_json(upstream, url, body:, bearer:, read_timeout:)
      call(upstream) do
        HTTParty.post(url, body: JSON.generate(body),
                      headers: { 'Authorization' => "Bearer #{bearer}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' },
                      open_timeout: OPEN_TIMEOUT, read_timeout: read_timeout)
      end
    end

    # The upstream's own words for a refusal: runnable:false's reason, report-server's
    # message (its envelope is {error: CODE, message}), the function's message or error,
    # or a plain-text body. Truncated, and never the request's own body.
    def self.reason(response)
      body = begin
        response.parsed_response
      rescue StandardError
        response.body
      end
      text = body.is_a?(Hash) ? (body['reason'] || body['message'] || body['error']) : body
      text.to_s.strip.truncate(REASON_MAX)
    end

    def self.refusal(upstream, response, status: 502, message: nil)
      reason = reason(response)
      name = NAMES.fetch(upstream)
      message ||= "#{name} answered #{response.code}"
      message = "#{message}: #{reason}" if reason.present?
      log(name, response.code, reason)
      Refusal.new(status, message, { upstream: name, status: response.code, reason: reason })
    end

    # What an operator greps for when a researcher reports a failed run. The reason is the
    # upstream's own refusal text; no request body, and so no token, is ever logged.
    def self.log(name, status, reason)
      Rails.logger.warn("researcher_dashboard.upstream_refusal upstream=#{name} status=#{status.inspect} reason=#{reason.inspect}")
    end

    # Net::HTTP's failures do not share an ancestor short of StandardError: a timeout is a
    # Timeout::Error, a dropped connection an IOError (EOFError) or a SystemCallError, a
    # garbled response Net::HTTPBadResponse, which descends from StandardError directly.
    CONNECTION_ERRORS = [SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError,
                         Net::HTTPBadResponse, Net::ProtocolError, HTTParty::Error].freeze

    def self.call(upstream)
      yield
    rescue Timeout::Error => e
      name = NAMES.fetch(upstream)
      log(name, nil, e.class.name)
      raise Refusal.new(504, "#{name} did not answer in time", { upstream: name, status: nil, reason: e.class.name })
    rescue *CONNECTION_ERRORS => e
      name = NAMES.fetch(upstream)
      log(name, nil, e.class.name)
      raise Refusal.new(502, "#{name} could not be reached", { upstream: name, status: nil, reason: e.class.name })
    end
    private_class_method :call, :log
  end
end
```

`Timeout::Error` covers both `Net::OpenTimeout` and `Net::ReadTimeout` (checked under WebMock). The connection errors are listed because they share no narrower ancestor: on the portal image's Ruby, `EOFError` descends from `IOError`, `Errno::ECONNRESET` from `SystemCallError`, and `Net::HTTPBadResponse` and `Net::ProtocolError` straight from `StandardError`. HTTParty returns a JSON body as a `Hash` and a `text/plain` one as a `String`, and `reason` reads either. Every refusal from an upstream writes one `researcher_dashboard.upstream_refusal` warning with the upstream, its status and its reason.

`rails/app/services/researcher_dashboard/profile_refresh.rb`:

```ruby
module ResearcherDashboard
  # Hands the class's assignment URLs to report-service's deriver. rigse answers as soon as
  # the function has queued the derivation; the app learns the result from the profile
  # document it is already listening to.
  module ProfileRefresh
    READ_TIMEOUT = 10

    def self.call(user:, clazz:)
      body = Scope.new(clazz).derive_profile_body
      response = Upstream.post_json(:function, "#{Settings.function_url}/derive-profile",
                                    body: body, bearer: Assertions.report_service_functions(user: user),
                                    read_timeout: READ_TIMEOUT)
      raise Upstream.refusal(:function, response, message: 'report-service refused the profile refresh') unless response.code == 202
      { queued: true, assignment_fingerprint: body[:assignment_fingerprint] }
    end
  end
end
```

**Specs** (WebMock; `disable_net_connect!` is already on):
- 202 `{queued: true, assignment_fingerprint}`; the stubbed request carried exactly `{class_hash, assignment_fingerprint, assignment_urls}` and a bearer that decodes with `aud: report-service-functions` and the researcher's `uid`; the fingerprint equals the metadata endpoint's for the same class
- the function answering 400 with `{"error": "..."}`: 502 whose `message` and `details.reason` carry the function's words and `details.status` 400
- a read timeout: 504; a refused connection, and a connection closed mid-response (`EOFError`): 502; each writes one `researcher_dashboard.upstream_refusal` log line and none contains the assertion
- `RESEARCHER_DASHBOARD_FUNCTION_URL` unset: 503 naming it, and no request
- an oversized list: 422 and no request
- a token for another class, and a non-researcher: 403 and no request
- `Upstream.reason` on a report-server envelope, a `runnable: false` body, a function body with `message`, a plain-text body, an unparsable JSON body, and a body over 300 characters

**Checked.** Built and run: 202 with the fingerprint, the posted body and the decoded assertion (`aud=report-service-functions`, the researcher's uid) as listed; the function's 400 came back 502 `report-service refused the profile refresh: assignment_urls[3] is longer than 2048 characters` with `details: {upstream: "report-service", status: 400, reason: ...}`; with the function URL unset, 503 `... RESEARCHER_DASHBOARD_FUNCTION_URL is not set`; 502 URLs, 422 with zero requests made.

---

### Resolve packages and queue them: the run path

**Summary**: Adds the run body's parser, the catalog resolve and `ResearcherDashboard::RunPackage`, and the `run_package` action. Resolves every package before minting anything, mints the runner tokens and the two assertions, posts once to `/run-package`, and answers with the queue state only. Covers R16 to R28.

**Files affected**:
- `rails/app/services/researcher_dashboard/run_request.rb` — new
- `rails/app/services/researcher_dashboard/catalog.rb` — new
- `rails/app/services/researcher_dashboard/run_package.rb` — new
- `rails/app/controllers/api/v1/researcher_dashboard_controller.rb` — `run_package`
- `rails/config/routes.rb` — the `run_package` route
- `rails/spec/services/researcher_dashboard/run_request_spec.rb`, `catalog_spec.rb`, `run_package_spec.rb` — new; `researcher_dashboard_controller_spec.rb` — a `run_package` block

**Estimated diff size**: ~480 lines

`rails/app/services/researcher_dashboard/run_request.rb`:

```ruby
module ResearcherDashboard
  # The run request's body, which is exactly {"packages": [{"identity", "version"}]}. The
  # scope is in the launch token and the checksum comes from the catalog, so any other key,
  # a checksum or package key above all, is refused rather than ignored.
  module RunRequest
    # The function's default queue cap; a larger batch could never be queued whole.
    MAX_PACKAGES = 20
    # REPORT-142 R3 and R7. \A and \z, not ^ and $, which match at a newline.
    IDENTITY = %r{\A(users|projects)/[0-9]+/[a-z0-9][a-z0-9-]{0,62}\z}
    VERSION = /\A[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?\z/

    def self.parse(raw)
      body = begin
        JSON.parse(raw.to_s)
      rescue JSON::ParserError
        invalid('The body must be a JSON object')
      end
      invalid('The body must be a JSON object') unless body.is_a?(Hash)
      extra = body.keys - ['packages']
      invalid("Unexpected keys in the body: #{extra.join(', ')}") if extra.any?
      packages = body['packages']
      unless packages.is_a?(Array) && packages.size.between?(1, MAX_PACKAGES)
        invalid("packages must be a list of 1 to #{MAX_PACKAGES} packages")
      end

      parsed = packages.each_with_index.map do |entry, i|
        invalid("packages[#{i}] must be an object") unless entry.is_a?(Hash)
        extra = entry.keys - %w[identity version]
        invalid("packages[#{i}] has unexpected keys: #{extra.join(', ')}") if extra.any?
        identity, version = entry['identity'], entry['version']
        invalid("packages[#{i}].identity is not a package identity") unless identity.is_a?(String) && IDENTITY.match?(identity)
        invalid("packages[#{i}].version is not a package version") unless version.is_a?(String) && VERSION.match?(version)
        { identity: identity, version: version }
      end
      # One result document per identity per class, so one batch cannot hold two versions.
      duplicate = parsed.group_by { |p| p[:identity] }.find { |_, v| v.size > 1 }&.first
      invalid("#{duplicate} appears more than once") if duplicate
      parsed
    end

    def self.invalid(message)
      raise Refusal.new(400, message)
    end
    private_class_method :invalid
  end
end
```

`rails/app/services/researcher_dashboard/catalog.rb`:

```ruby
module ResearcherDashboard
  # The run path's one read of report-server's catalog. It presents the app's own launch
  # token, so report-server applies its visibility rule to this researcher, and it is the
  # only place a checksum or catalog id comes from.
  module Catalog
    # report-server reads the caller's grants from the portal with a five-second timeout.
    READ_TIMEOUT = 10
    CHECKSUM = /\Asha256:[0-9a-f]{64}\z/

    def self.resolve(identity:, version:, launch_token:)
      response = Upstream.get(:report_server, "#{Settings.report_server_url}/api/v1/packages/resolve",
                              query: { identity: identity, version: version }, bearer: launch_token,
                              read_timeout: READ_TIMEOUT)
      label = "#{identity}@#{version}"
      case response.code
      when 200
        body = response.parsed_response
        unless body.is_a?(Hash) && body['identity'] == identity && body['version'] == version &&
               CHECKSUM.match?(body['checksum'].to_s) && body['catalog_id'].is_a?(Integer) && body['catalog_id'] > 0 &&
               [true, false].include?(body['runnable'])
          raise Refusal.new(502, "report-server's answer for #{label} is not a resolved package",
                            { upstream: 'report-server', status: 200, reason: 'malformed resolve answer' })
        end
        unless body['runnable']
          raise Upstream.refusal(:report_server, response, status: 409, message: "#{label} cannot be run")
        end
        { identity: identity, version: version, checksum: body['checksum'], catalog_id: body['catalog_id'],
          clue_prepull: body['clue_prepull'] == true }
      when 404
        raise Refusal.new(409, "#{label} cannot be resolved: it does not exist or you may not see it",
                          { upstream: 'report-server', status: 404, reason: Upstream.reason(response) })
      else
        raise Upstream.refusal(:report_server, response, message: "report-server could not resolve #{label}")
      end
    end
  end
end
```

`clue_prepull` is read from the resolve answer, which REPORT-142 was amended to carry (2026-09-24). `== true` treats an absent field as false, so a report-server deployed before that amendment mints no CLUE token rather than failing the run.

`rails/app/services/researcher_dashboard/run_package.rb`:

```ruby
module ResearcherDashboard
  # Queues a batch of packages for one researcher on one class. It resolves every package
  # before it mints or sends anything, so a batch queues whole or not at all; mints the
  # runner tokens; and hands everything to the function, answering as soon as the function
  # has accepted the work. It never waits for a VM. The tokens go only to the function, and
  # only the queue state comes back, so no runner claim reaches the browser.
  class RunPackage
    # The function records the queue before it touches a VM and never waits for one.
    READ_TIMEOUT = 25

    def self.call(user:, clazz:, packages:, launch_token:)
      new(user: user, clazz: clazz, packages: packages, launch_token: launch_token).call
    end

    def initialize(user:, clazz:, packages:, launch_token:)
      @user = user
      @clazz = clazz
      @packages = packages
      @launch_token = launch_token
    end

    def call
      resolved = @packages.map { |p| Catalog.resolve(**p, launch_token: @launch_token) }
      firebase_app = Settings.firebase_app
      # Minted whenever a package asks for the CLUE pre-pull, whatever the runner does with
      # it: rigse learning the runner's configuration would be the wrong coupling (section 13).
      apps = [firebase_app]
      apps << Settings.clue_firebase_app if resolved.any? { |r| r[:clue_prepull] }
      url = "#{Settings.function_url}/run-package"

      response = Upstream.post_json(:function, url, body: body(resolved, apps, firebase_app),
                                    bearer: Assertions.report_service_functions(user: @user),
                                    read_timeout: READ_TIMEOUT)
      case response.code
      when 202
        accepted = begin
          response.parsed_response
        rescue StandardError
          nil
        end
        unless accepted.is_a?(Hash)
          raise Refusal.new(502, 'report-service accepted the run but its answer was not the queue state',
                            { upstream: Upstream::NAMES[:function], status: 202, reason: 'malformed 202 body' })
        end
        # Only the queue state: nothing else the function says reaches the browser.
        accepted.slice('queue', 'appended', 'vm')
      when 409
        raise Upstream.refusal(:function, response, status: 409, message: 'report-service refused the run')
      else
        raise Upstream.refusal(:function, response, message: 'report-service refused the run')
      end
    rescue Refusal => e
      raise unless e.status == 504 && e.details&.dig(:upstream) == Upstream::NAMES[:function]
      # REPORT-141 records the queue before it asks for a VM, so the work may be waiting.
      raise Refusal.new(504, 'report-service did not answer in time; the packages may already be queued', e.details)
    end

    private

    def body(resolved, apps, firebase_app)
      {
        packages: resolved.map { |r| r.slice(:identity, :version, :checksum, :catalog_id) },
        scope: {
          kind: 'class',
          collection: 'classes',
          id: @clazz.class_hash,
          classes: [{ class_hash: @clazz.class_hash, class_id: @clazz.id }],
          assignments: Scope.new(@clazz).run_assignments
        },
        class_tokens: apps.index_with { |app| RunnerTokens.class_token(user: @user, clazz: @clazz, firebase_app: app) },
        session_token: RunnerTokens.session_token(user: @user, firebase_app: firebase_app),
        firebase_project: firebase_app,
        # An assertion, not a token: the function exchanges it at report-server only when it
        # launches a VM, so the reuse branch leaves the running VM's token alone.
        report_server_assertion: Assertions.report_server(user: @user, clazz: @clazz)
      }
    end
  end
end
```

Resolves run one at a time and stop at the first refusal, so the portal load report-server generates (one short portal read per resolve, REPORT-142 R15) stays one request deep, and a refused batch costs no more resolves than it needs. The settings are read after the resolves and before anything is minted, so a missing one is a 503 with nothing sent.

**Specs** (WebMock stubs for the resolve, `https://<REPORT_SERVER_URL>/api/v1/packages/resolve?identity=...&version=...`, and for `/run-package`):
- `RunRequest.parse`: accepts one and twenty packages and a prerelease version; refuses a non-object body, malformed JSON, an extra top-level key, an empty list, 21 packages, an entry with `checksum`, `package_key` or `catalog_id`, an identity with an underscore, a trailing newline or no origin, a version that is not `MAJOR.MINOR.PATCH`, and a repeated identity
- `Catalog.resolve`: sends the launch token as the bearer and no `Origin`, URL-encodes the identity; 200 runnable returns the checksum and catalog id; 404 is a 409 `Refusal`; `runnable: false, reason: "archived"` is a 409 naming the reason; a 200 whose identity, version, checksum or catalog id does not match is 502; 503 is 502 carrying report-server's `message`; a timeout is 504
- the action:
  - 202 with exactly `queue`, `appended` and `vm`, dropping any other key the function returns, and no string beginning `eyJ` anywhere in the body
  - the posted body has exactly the R22 keys; `packages` in request order with the resolved checksums and catalog ids; `scope` `{kind: "class", collection: "classes", id: class_hash, classes: [{class_hash, class_id}], assignments}` with the metadata endpoint's assignments minus `tool`; `firebase_project` and one `class_tokens` key, the report-service FirebaseApp; a session token without `class_hash`; `report_server_assertion` decoding with `aud: report-server`; the bearer decoding with `aud: report-service-functions`
  - a batch with a `clue_prepull: true` resolve answer: `class_tokens` gains the CLUE FirebaseApp, whose token carries the class hash
  - five packages whose third resolve is 404: 409 naming it, the fourth and fifth never resolved, `/run-package` never called
  - archived: 409 `... cannot be run: archived`, `/run-package` never called
  - the function's 409: 409 carrying `queue at its cap (20 outstanding)`; its 502 with a plain-text body: 502 carrying that text; its read timeout: 504 saying the packages may already be queued; a 202 whose body is not a JSON object: 502
  - two researchers of the same class running the same package: each request is answered 202 from its own stubbed response, and each posted body's assertions carry its own `uid`
  - `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` unset: 202 for a batch without `clue_prepull`, 503 for one with it, with nothing sent to the function

**Checked.** Built and run against stubs: the posted body had the keys `packages, scope, class_tokens, session_token, firebase_project, report_server_assertion`, the scope block and tokens as listed, the resolve requests carried the launch token and no `Origin`, and the 202 body was `{queue, appended, vm}` without the extra key the stub returned. A two-package batch whose second package answered 404 was 409 `projects/20/b@1.0.0 cannot be resolved: ...` with `/run-package` called zero times; archived was 409 `... cannot be run: archived`; `checksum` in an entry, an extra top-level key, a duplicate identity, an identity with an embedded newline, an empty list, a JSON array and malformed JSON were each 400; the function's 409 and plain-text 502 were passed through with their reasons; a function read timeout was 504 with the may-be-queued message; a resolve timeout 504; a resolve 503 was 502 carrying `portal did not answer`; a resolve connection closed with `EOFError` 502 `report-server could not be reached`; a 202 with a plain-text body 502.

---

### Configure the dashboard's services

**Summary**: Wires the four settings through local Docker, both ECS task definitions and the stack parameters, and documents them beside RIGSE-367's Researcher Dashboard section. Covers R29.

**Files affected**:
- `docker-compose.yml` — the four variables in the app service, beside the `REPORT_SERVICE_*` block, with staging-shaped defaults for the two URLs and the two FirebaseApp names (the same pattern `REPORT_SERVICE_URL` uses there)
- `configs/cloudformation/stack_template.yml` — parameters `ReportServerURL`, `ResearcherDashboardFunctionURL`, `ResearcherDashboardFirebaseApp` and `ResearcherDashboardClueFirebaseApp`, each `Type: String` with `Default: ""` and a description naming the staging value; their four `Name`/`Value` entries in both `AppTaskDefinition` and `WorkerTaskDefinition`, beside `REPORT_SERVICE_URL`
- `README.md` — the RIGSE-367 "Researcher Dashboard" section gains the four variables

**Estimated diff size**: ~70 lines

The README states what each variable points at, per environment (staging: `https://report-server.concordqa.org`, `https://us-central1-report-service-dev.cloudfunctions.net/researcherDashboard`, `report-service-dev`, `collaborative-learning-staging`; production: the production report-server, `report-service-pro`, and CLUE's production project), that the two FirebaseApp names must be rows in the portal's `firebase_apps` table (which `jwt/firebase` already needs for the app's own tokens), that `REPORT_SERVICE_URL` and `REPORT_SERVICE_BEARER_TOKEN` are unrelated and stay for feedback metadata, and that `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` goes away with RIGSE-369.

**Getting it onto a stack.** As in RIGSE-367, the release skill updates stacks with `--use-previous-template`, so a release adds neither the parameters nor their environment entries; the metadata endpoint works without them and the refresh and run path answer 503 naming the missing setting. Enabling them is the same deliberate template update per environment that RIGSE-367 describes, and can be the same one.

**Specs**: none for configuration. The check is a stack template lint (`cfn-lint` in a `python:3.12-slim` container) and `docker compose config` showing the four variables.

---

## Open Questions

<!-- Implementation-focused questions only. Requirements questions go in requirements.md. -->

### RESOLVED: Judgment call: one `Refusal` type rendered by `rescue_from`, rather than status handling in the controller
**Options considered**:
- A) Services raise `ResearcherDashboard::Refusal(status, message, details)` and the controller renders it once.
- B) Services return result objects and the controller maps each outcome to a status, as the spike's controller did with three rescue clauses.

**Decision**: A. The run path has a dozen distinct refusals across three services, and R28 requires every one to have the same body shape; one `rescue_from` makes that true by construction and keeps the actions to two lines each. The spike's mapping (`e.status.to_i == 409 ? 409 : 502`) is the pattern R23 keeps, now inside `Upstream.refusal`.

### RESOLVED: Judgment call: read timeouts of 10 seconds for the resolve and the refresh, 25 for `/run-package`
**Options considered**:
- A) 10, 10 and 25 seconds, with a 5-second open timeout everywhere.
- B) HTTParty's default (none set, so Net::HTTP's 60 seconds).

**Decision**: A. The resolve's slowest honest answer is report-server's five-second portal timeout (REPORT-142 R15) plus its own work; the refresh only enqueues a Cloud Task; `/run-package` records the queue and makes at most `GetMicrovm`, a Firestore transaction, report-server's mint and `RunMicrovm`, none of which waits for a VM. None of these is the old wait: each bounds one call that should take a second or two, so a hung upstream is reported in seconds rather than holding a Puma thread for a minute. A `/run-package` timeout says the work may be queued, which is true because REPORT-141 writes the queue first (R27).

### RESOLVED: Judgment call: resolve sequentially and stop at the first refusal
**Options considered**:
- A) One resolve at a time, stopping at the first refusal.
- B) All resolves in parallel threads.

**Decision**: A. A batch is at most 20 and typically one to three; each resolve makes report-server read the portal (REPORT-142 R15), so parallel resolves multiply portal load for a saving of a second at most. Stopping early also means a refused batch reports the first bad package and costs nothing more.

## Self-Review

Roles: the reviewer of the resulting commits, the engineer running the tests, the operator running it, Security Engineer, Senior Rails Engineer. Every step was built as throwaway code and run; each finding below was reproduced before it was recorded. Candidates dropped after checking:
- Step independence. With steps 4 and 5 removed, step 3's controller answered 200; step 5 uses only what steps 1, 2 and 4 add.
- The `jwt_controller` refactor. Its three spec files pass unchanged (72 examples), and the extracted `user_id` equals the deleted helper's.
- Error messages echoing `check_for_auth_token`'s reason ("Invalid audience. Expected researcher-dashboard, received report-server"). They describe the refused token to its own holder and carry no secret.
- The Rails request log. With `wrap_parameters false` the logged parameters are the caller's own `packages`, and nothing in the plan logs an outbound body.

### Senior Rails Engineer

#### RESOLVED: A dropped connection or a garbled response would still surface as a Rails 500
`Upstream` rescued `Timeout::Error`, `SocketError`, `SystemCallError`, SSL errors and `HTTParty::Error`. On the portal image's Ruby, `EOFError` (a connection closed mid-response) descends from `IOError`, and `Net::HTTPBadResponse` and `Net::ProtocolError` from `StandardError` directly, so none was caught, against R27. Fixed: `Upstream::CONNECTION_ERRORS` adds `IOError`, `Net::HTTPBadResponse` and `Net::ProtocolError`. Checked: a resolve stubbed to raise `EOFError` now answers 502 `report-server could not be reached`.

#### RESOLVED: A 202 whose body is not a JSON object raised `ArgumentError`
`response.parsed_response.slice('queue', 'appended', 'vm')` is `String#slice` when the body is text, and `String#slice` with three string arguments raises `ArgumentError` (checked on the portal image), which would be a 500 after the work was queued. Fixed: `RunPackage` answers 502 naming the malformed answer unless the body is a Hash. Checked: a stubbed `text/plain` 202 answers 502.

### Operator

#### RESOLVED: Nothing recorded an upstream refusal server-side
The plan reported each refusal's reason to the browser (R28) and wrote nothing to the portal's log, so a researcher's "my run failed" had no server-side trace beyond a 502 status line. Fixed: `Upstream` writes one `researcher_dashboard.upstream_refusal upstream=... status=... reason=...` warning for every refusal, timeout and connection failure, with no request body and so no token. Stage 8 found no requirement for it; Doug added it as R30 (2026-09-24).

### Engineer running the tests

#### RESOLVED: Every action answers 404 unless the specs enable the dashboard
`ResearcherDashboard.enabled?` needs `RESEARCHER_DASHBOARD_URL` as well as the signing key, and `spec_helper.rb` sets only the key (RIGSE-367 step 1). The first throwaway run of the disabled case confirmed the 404. Fixed: step 3 states the harness, an `around` hook setting and restoring the five variables.
