# Implementation Plan: Forwarded-Student Portal Auth

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-352
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Verified implementation facts (research summary)

Every claim below was checked against the current source (and, where noted, against a live throwaway test in the app container) before this plan was written.

- **The real Warden strategy chain is not reliably exercisable from request/controller specs.** A throwaway `type: :request` spec that sent a valid Google OIDC `Bearer` token (with `GoogleOidcVerifier.verify` stubbed) and an active mapped client did **not** resolve `current_user` — the OIDC strategy's `valid?` was never even called for the success case, while an "invalid token" variant of the same request *did* reach `authenticate!`. The flow is confounded by Devise's test warden shim (`Devise::Test::ControllerHelpers#_catch_warden`), session/CSRF handling, and strategy ordering. This is exactly why every existing OIDC test (`spec/controllers/api/v1/oidc_auth_spec.rb`, `spec/libs/bearer_token/oidc_bearer_token_authenticatable_spec.rb`) either **mocks `current_user` and stamps `request.env` by hand**, or drives the **strategy object in isolation**. This plan's test strategy follows that split (see the testing step) rather than trying to assert the full middleware chain.
- Production *does* authenticate the spring report-service flow as the mapped user through `current_user` → OIDC strategy → `success!(oidc_client.user)`; the request-spec quirk above is a harness artifact, not a production one. `check_for_auth_token` already references `current_user` on the OIDC branch (`api_controller.rb:50`), so forcing the chain from a controller filter is sound at runtime.
- `Admin::OidcClient` (oidc_client.rb): `belongs_to :user`, `validates :user, presence: true`, `validates :name/:sub`, unique `sub`, `active` scope. Column `user_id` is `NOT NULL` (schema.rb:91). `belongs_to_required_by_default = false` app-wide, so the bare `belongs_to` is already optional; presence is enforced only by the explicit validation.
- `Admin::Settings` uses `serialize :enabled_bookmark_types, type: Array` on a `text` column and nil-guards it via `self.enabled_bookmark_types ||= []` in `init` (settings.rb:8,34). This is the capabilities-column precedent.
- OIDC strategy (oidc_bearer_token_authenticatable.rb): no `store?` override; fails with non-bang `fail(:invalid_token)`; stamps `portal.auth_strategy`/`auth_client` (name)/`auth_details`; `success!(oidc_client.user)` at line 47. `valid?` gates on a Google-issuer `Bearer` token; `oidc_token_value` declines `Bearer/JWT`.
- `SignedJwt.decode_firebase_token(token, app_name)` (signed_jwt.rb:68) resolves a `FirebaseApp` **by name** and `JWT.decode(..., true, {algorithm: 'RS256'})` — signature + `exp` with **no `exp_leeway`**. `create_firebase_token` backdates `iat` by `CLOCK_SKEW_ALLOWANCE = 30`.
- Learner Firebase token claims: nested `claims` object with `platform_id` (= `APP_CONFIG[:site_url]`) and `platform_user_id` (integer `user.id`) set in the shared base `sub_claims` (`jwt_controller.rb:233-234`, so present on every token shape), plus the learner-branch merge (`jwt_controller.rb:266-270`) adding `user_type: "learner"` (learner-exclusive - the discriminator this story keys on), `class_hash` (= `offering.clazz.class_hash`), and `offering_id` (= `offering.id`); top-level `iss` = `sub` = app `client_email` (set inside `SignedJwt.create_firebase_token`, signed_jwt.rb:49-50). Identity resolution reads `claims['platform_user_id']`. Note `class_hash` is also set in the researcher/teacher/else branches and `offering_id` in the else branch, but `user_type: "learner"` is set only by the learner branch, so it (not `offering_id`/`class_hash`) is the fail-closed learner check.
- `API::APIController#error(message, status=400, details=nil)` renders `{success, response_type:"ERROR", message, details?}` — **no `error_code` slot** (api_controller.rb:86). `record_not_found` renders **404**; `pundit_user_not_authorized` renders **403 `{success:false, message:"Not authorized"}`**.
- `API::V1::OfferingsController#update_student_metadata` (offerings_controller.rb:53) does `authorize offering, :update?`, then `offering.clazz.students.find_by(user_id:)` (404 if absent), then upserts `UserOfferingMetadata` from `permit(:active, :locked)`. `#update` (line 27) authorizes the bare `:update?` and writes class-wide.
- `API::V1::StudentsController#add_to_class` (students_controller.rb:183) does `authorize portal_clazz, :update_roster?`, then `authorize student, :show?`, then `student.add_clazz`. `#remove_from_class` (line 203) authorizes the bare `:update_roster?` then destroys a `StudentClazz`.
- `Portal::Clazz`: `has_many :teachers, through: :teacher_clazzes` (clazz.rb:21); `is_archived` boolean column defaulting false; `class_hash`, `class_word` present. `Portal::Student#add_clazz(clazz)` (student.rb:166) and `belongs_to :user` (student.rb:6) exist. `User has_one :portal_student` (user.rb:38). `User` is `:trackable` (user.rb:9-11).
- `APP_CONFIG` is built from `config/settings.yml` by `lib/load_config.rb` (`Object.const_set(:APP_CONFIG, app_config)`); the app-name allowlist is added there as a new key.
- Routes: `add_to_class` (routes.rb:340), `update_student_metadata` (routes.rb:398), `oidc_send` (routes.rb:362). Warden failure app is `CustomFailure` (devise.rb:278), which only `http_auth`/redirects — it does not render the API JSON error body.

## Design decisions taken in this plan (implementation-level)

1. **Auth-error rendering mechanism = controller-level detect-and-render** (not strategy `fail!` + `CustomFailure`). Requirements verified that strategy `fail!` never reaches `CustomFailure` under this app's lazy `current_user`. The strategy stamps a machine code in `request.env['portal.auth_error']` and fails; a small `ForwardedAuthGuard` concern (a `prepend_before_action`) forces the chain via `current_user` and renders `401 + error_code` from `request.env`. This keeps the identity-switch in the auth layer while producing the cross-repo contract at the controller layer, and is testable with the established mock-`current_user`/stamp-`request.env` pattern.
2. **Forwarded-token verification lives in a dedicated `ForwardedFirebaseToken` PORO in `lib/`**, not inline in the strategy. It performs every fail-closed check and returns a small result (`user`, `origin_offering`, `origin_clazz`) or raises `ForwardedFirebaseToken::Invalid` with a reason symbol. This keeps the strategy thin and makes the whole check unit-testable off the request path (the strategy's own integration is thin glue).
3. **Origin objects are resolved and validated once, at auth time**, inside `ForwardedFirebaseToken`; the strategy stamps `origin_offering_id` and `origin_class_hash`, and `OidcAuthContext#origin_offering`/`#origin_clazz` re-resolve via `find_by` for policy convenience (safe: the class_hash cross-check already passed at auth time).
4. **Client is resolved downstream by stable id** (`request.env['portal.auth_client_id']`), never by `portal.auth_client` (name, kept display-only).
5. **Opt-in gate keys on `capabilities.present? OR requires_forwarded_jwt?`, not capabilities alone** (external-review outcome). The two fields are orthogonal: `requires_forwarded_jwt` is an identity choice ("act as the forwarded student, no mapped-user fallback"), while `capabilities` are the extra lifecycle powers beyond a normal student. Keying the gate on capabilities alone made a `requires_forwarded_jwt=true` client with empty capabilities fall through to `success_as_mapped_user!` - which authenticates as the (Phase-2 nil) mapped user via `success!(nil)`, surfacing as a confusing 403, or, if `user_id` were still set, silently ignores the "no mapped-user fallback" guarantee. Including `requires_forwarded_jwt?` in the gate fixes both (header-absent now returns the correct `401 forwarded_token_required`; `success!(nil)` is unreachable). We deliberately did **not** add a model validation forbidding `requires_forwarded_jwt=true` + empty capabilities, because that is a legitimate future configuration: a forwarded-identity client that acts as the student for ordinary student-scoped operations only, holding none of the three elevated lifecycle capabilities. Forbidding it in the model would foreclose that feature; the gate already handles the state correctly.

---

## Implementation Plan

### OidcClient schema migration, capabilities registry, and conditional validation

**Summary**: The Phase-1-safe schema + model foundation. Makes `user_id` nullable, adds `requires_forwarded_jwt` (`default: false, null: false`) and a generic serialized `capabilities` column, adds the `CAPABILITIES` registry and `capability?` predicate, and makes user-presence conditional. No data flip here (that is the Phase-2 step).

**Files affected**:
- `rails/db/migrate/<ts>_add_forwarded_jwt_to_admin_oidc_clients.rb` — new migration
- `rails/app/models/admin/oidc_client.rb` — registry, predicate, validations, nil-guard
- `rails/db/schema.rb` — regenerated
- `rails/spec/models/admin/oidc_client_spec.rb` — extend

**Estimated diff size**: ~140 lines

Migration:

```ruby
class AddForwardedJwtToAdminOidcClients < ActiveRecord::Migration[8.0]
  def change
    # Phase-1-safe schema only. The Phase-2 data flip (null user_id,
    # requires_forwarded_jwt=true) is a separate rake task, not this migration.
    change_column_null :admin_oidc_clients, :user_id, true
    add_column :admin_oidc_clients, :requires_forwarded_jwt, :boolean, null: false, default: false
    add_column :admin_oidc_clients, :capabilities, :text
  end
end
```

Model (full new file):

```ruby
class Admin::OidcClient < ApplicationRecord
  self.table_name = 'admin_oidc_clients'

  # Single source of truth for recognized per-operation capabilities:
  # identifier => human-readable label (used by the admin form and validation).
  CAPABILITIES = {
    'enroll_student'        => 'Enroll a forwarded student into a class',
    'update_offering_state' => 'Lock, hide, or open a forwarded student\'s offering',
    'send_teacher_email'    => 'Send a notification email to the student\'s teacher'
  }.freeze

  serialize :capabilities, type: Array

  belongs_to :user

  validates :name, presence: true
  validates :sub, presence: true, uniqueness: true
  # A legacy/fallback client (Phase 1) still requires a mapped user; only a
  # client flipped to require the forwarded JWT (Phase 2) may have a null user.
  validates :user, presence: true, unless: :requires_forwarded_jwt?
  validate :capabilities_are_recognized

  scope :active, -> { where(active: true) }

  # A serialize Array column has no value-level default and the admin form omits
  # the param when nothing is checked, so `capabilities == nil` is a real persisted
  # state. We nil-guard at the two use sites below (non-mutating) rather than
  # overriding the getter; the opt-in gate relies on `nil.present? == false`.
  def capability?(name)
    (capabilities || []).include?(name.to_s)
  end

  private

  def capabilities_are_recognized
    unknown = (capabilities || []) - CAPABILITIES.keys
    return if unknown.empty?
    errors.add(:capabilities, "contains unknown capabilities: #{unknown.join(', ')}")
  end
end
```

Model spec additions:
- `capability?` true/false against a stored set; `capability?` on a `capabilities == nil` record returns false and does not raise (via the use-site nil-guard, no getter override).
- Validation rejects an unknown capability identifier; no-ops on nil/empty.
- Conditional user presence: `requires_forwarded_jwt=false` + null user **rejected**; `requires_forwarded_jwt=true` + null user **allowed**; `requires_forwarded_jwt=false` + user **allowed**.

---

### Admin CRUD: capabilities checkboxes and requires_forwarded_jwt

**Summary**: Render one checkbox per registered capability (label as help text) plus the `requires_forwarded_jwt` toggle, and permit the new params. Mirrors the existing `active` `check_box` pattern.

**Files affected**:
- `rails/app/views/admin/oidc_clients/_form.html.haml` — add checkboxes
- `rails/app/controllers/admin/oidc_clients_controller.rb` — permit params
- `rails/spec/controllers/admin/oidc_clients_controller_spec.rb` — edit renders with nil capabilities; permitted-params round-trip

**Estimated diff size**: ~40 lines

Form (append inside the existing `%ul.menu_v`):

```haml
        %li
          Requires forwarded student JWT (Phase 2 — no mapped-user fallback):
          = f.check_box :requires_forwarded_jwt
        %li
          Capabilities:
          %ul
            - Admin::OidcClient::CAPABILITIES.each do |identifier, label|
              %li
                -# Use the model's nil-safe predicate: existing clients read back
                -# capabilities == nil right after the migration, so a raw
                -# `capabilities.include?` here would raise NoMethodError on edit.
                = check_box_tag "admin_oidc_client[capabilities][]", identifier, oidc_client.capability?(identifier), id: "capability_#{identifier}"
                = label_tag "capability_#{identifier}", label
          -# Ensures capabilities is submitted (and cleared) even when none are checked
          = hidden_field_tag "admin_oidc_client[capabilities][]", ""
```

Controller permitted params:

```ruby
  def oidc_client_params
    params.require(:admin_oidc_client)
          .permit(:name, :sub, :email, :user_id, :active, :requires_forwarded_jwt, capabilities: [])
          .tap { |p| p[:capabilities] = Array(p[:capabilities]).reject(&:blank?) if p.key?(:capabilities) }
  end
```

(The hidden `""` entry keeps the key present so unchecking all clears the set; the `reject(&:blank?)` drops the sentinel.)

Spec coverage:
- Rendering the edit form for a client with `capabilities == nil` (an existing pre-migration client) does not raise and renders all capability checkboxes unchecked (guards the nil-safe `capability?` use in the form).
- Submitting checked capabilities persists them; submitting with none checked clears the set to `[]` (the hidden-field sentinel path).

---

### Forwarded Firebase token verification (SignedJwt iss-resolution + ForwardedFirebaseToken PORO)

**Summary**: Add an `iss`-resolved Firebase verification to `SignedJwt` (select the `FirebaseApp` RSA key from the token's `iss` = `client_email`, zero `exp_leeway`), and a `ForwardedFirebaseToken` PORO that runs every fail-closed check and returns the acting user + resolved origin offering/clazz. Config allowlist added to `settings.yml`/`load_config`.

**Files affected**:
- `rails/lib/signed_jwt.rb` — add `decode_firebase_token_by_iss`
- `rails/lib/forwarded_firebase_token.rb` — new PORO
- `rails/config/settings.sample.yml` — allowlist key (the tracked sample; `rails/config/settings.yml` is gitignored and is **not** a shipped change - see the config note below)
- `rails/spec/libs/forwarded_firebase_token_spec.rb` — new
- `rails/spec/libs/signed_jwt_spec.rb` (existing signed_jwt spec) — iss-resolution case

**Estimated diff size**: ~200 lines

`SignedJwt` addition (resolves the app by `iss`, not name; keeps zero leeway):

```ruby
  # Verify a forwarded Firebase custom token, selecting the RSA key from the
  # token's `iss` (= FirebaseApp#client_email) rather than a caller-supplied
  # app name. Signature + exp are enforced with zero clock-skew (intentional:
  # the portal both mints and re-verifies on its own clock). Returns
  # {data:, header:, app:}. Raises SignedJwt::Error on any failure.
  def self.decode_firebase_token_by_iss(token)
    unverified = begin
      JWT.decode(token, nil, false).first
    rescue StandardError => e
      raise SignedJwt::Error.new("Undecodable forwarded token: #{e.message}")
    end
    iss = unverified && unverified['iss']
    raise SignedJwt::Error.new('Forwarded token has no iss') if iss.blank?

    apps = FirebaseApp.where(client_email: iss).to_a
    raise SignedJwt::Error.new("No FirebaseApp for iss=#{iss}") if apps.empty?
    # client_email is not unique-indexed; disambiguation against the name
    # allowlist happens in ForwardedFirebaseToken. Here, if more than one app
    # shares the email, verify against whichever key validates the signature.
    app, decoded = verify_against_any(token, apps)
    raise SignedJwt::Error.new("Signature did not verify for iss=#{iss}") unless app
    { data: decoded[0], header: decoded[1], app: app }
  end

  def self.verify_against_any(token, apps)
    apps.each do |app|
      begin
        rsa = OpenSSL::PKey::RSA.new(app.private_key)
        decoded = JWT.decode(token, rsa, true, { algorithm: rsa_algorithm })
        return [app, decoded]
      rescue JWT::ExpiredSignature
        raise SignedJwt::Error.new('Forwarded token expired')
      rescue StandardError
        next
      end
    end
    [nil, nil]
  end
```

`ForwardedFirebaseToken` PORO (all fail-closed checks; raises a single `Invalid` with a reason):

```ruby
class ForwardedFirebaseToken
  class Invalid < StandardError
    attr_reader :reason
    def initialize(reason)
      @reason = reason           # e.g. :expired, :signature, :platform_id, :app_not_allowed, ...
      super(reason.to_s)
    end
  end

  Result = Struct.new(:user, :origin_offering, :origin_clazz, keyword_init: true)

  # Default allowlist if config omits the key.
  DEFAULT_APP_NAMES = %w[report-service-pro report-service-dev].freeze

  def self.allowed_app_names
    Array(APP_CONFIG[:forwarded_firebase_app_names]).presence || DEFAULT_APP_NAMES
  end

  def self.verify(token)
    new(token).verify
  end

  def initialize(token)
    @token = token
  end

  def verify
    decoded = decode!                        # signature + exp (raises :expired/:signature)
    app = decoded[:app]
    raise Invalid.new(:app_not_allowed) unless self.class.allowed_app_names.include?(app.name)

    claims = decoded[:data]['claims'] || {}
    raise Invalid.new(:platform_id) unless claims['platform_id'] == APP_CONFIG[:site_url]
    raise Invalid.new(:not_learner) unless claims['user_type'] == 'learner'

    user = User.find_by(id: claims['platform_user_id'])
    raise Invalid.new(:user_unresolved) unless user && user.portal_student

    offering = Portal::Offering.find_by(id: claims['offering_id'])
    raise Invalid.new(:offering_unresolved) unless offering
    clazz = offering.clazz
    raise Invalid.new(:clazz_unresolved) unless clazz
    raise Invalid.new(:class_hash_mismatch) unless clazz.class_hash == claims['class_hash']

    Result.new(user: user, origin_offering: offering, origin_clazz: clazz)
  end

  private

  def decode!
    SignedJwt.decode_firebase_token_by_iss(@token)
  rescue SignedJwt::Error => e
    raise Invalid.new(e.message.include?('expired') ? :expired : :signature)
  end
end
```

Config: add the key only to the **tracked** `settings.sample.yml` under the shared anchor. `rails/config/settings.yml` is gitignored (`git check-ignore` confirms; only `settings.sample.yml` is in `git ls-files`), so a change there is never reviewed or deployed and must not be relied on. The code already falls back to `ForwardedFirebaseToken::DEFAULT_APP_NAMES` when the key is absent (`allowed_app_names` above), so omitting it in any given environment is safe. Any real per-environment production/staging override of the allowlist is therefore an **external deploy/runbook step** (edit the deployed environment's config), not a tracked-file change in this repo.

```yaml
  # rails/config/settings.sample.yml (tracked), under the shared anchor
  :forwarded_firebase_app_names:
    - report-service-pro
    - report-service-dev
```

**Testability note (from requirements):** forwarded-path specs mint tokens via `spec/support/firebase_test_helper.rb`, which creates a `FirebaseApp` named `"test app"` with `client_email: "user@example.com"`. Specs must either add `"test app"` to the allowlist (`stub_const`/config override) or create the test app under an allowlisted name, and the minted token's `iss` must equal that app's `client_email` (it does — `create_firebase_token` sets `iss = app.client_email`). Mint learner-shaped tokens with the nested `claims` object matching `jwt_controller.rb:263-270`.

Specs:
- `decode_firebase_token_by_iss`: verifies a good token, rejects a wrong-key token (`:signature`), rejects an expired token (`:expired`), rejects unknown `iss`.
- `ForwardedFirebaseToken.verify`: happy path returns user/offering/clazz; each failure mode raises `Invalid` with the right reason (app not allowed, platform_id mismatch, non-learner, user without portal_student, missing offering, nil clazz, class_hash mismatch, expired, bad signature).

---

### OidcAuthContext PORO and ApplicationPolicy accessor

**Summary**: The shared request-scoped surface consumed by policies (R1) and controllers (R1 + R2). Constructible from a request or a bare env hash. `ApplicationPolicy#oidc_context` is a convenience for policies in that hierarchy.

**Files affected**:
- `rails/lib/oidc_auth_context.rb` — new PORO
- `rails/app/policies/application_policy.rb` — memoized accessor
- `rails/spec/libs/oidc_auth_context_spec.rb` — new

**Estimated diff size**: ~90 lines

```ruby
class OidcAuthContext
  # Accept a request (responds to #env) or a bare env hash (for tests / Struct policies).
  def initialize(request_or_env)
    @env = request_or_env.respond_to?(:env) ? request_or_env.env : (request_or_env || {})
  end

  def client
    return @client if defined?(@client)
    id = @env['portal.auth_client_id']
    @client = id ? Admin::OidcClient.find_by(id: id) : nil
  end

  def acting_as_forwarded_user?
    !!@env['portal.forwarded_student']
  end

  def origin_offering_id
    @env['portal.origin_offering_id']
  end

  def origin_class_hash
    @env['portal.origin_class_hash']
  end

  # Resolved objects (verified once at auth time; re-resolved here for convenience).
  def origin_offering
    return nil unless origin_offering_id
    @origin_offering ||= Portal::Offering.find_by(id: origin_offering_id)
  end

  def origin_clazz
    origin_offering&.clazz
  end

  def capability?(name)
    !!client&.capability?(name)
  end
end
```

`ApplicationPolicy` accessor (guarded against a nil request, which is the common bare-User test path):

```ruby
  def oidc_context
    @oidc_context ||= OidcAuthContext.new(request)
  end
```

(`OidcAuthContext.new(nil)` yields an empty-env context whose predicates all return false/nil, so policies constructed with a bare `User` — `request == nil` — behave exactly as before.)

Spec: build from a fake env hash; assert `client`, `acting_as_forwarded_user?`, origin ids/objects, and `capability?` delegation; assert an empty env yields all-false/nil.

---

### Rewrite the OIDC bearer strategy for the forwarded-student override

**Summary**: The crux. Adds forwarded-JWT handling to `authenticate!`: opt-in gate (capabilities present, or `requires_forwarded_jwt` set), Phase-1 header-absent fallback (with tripwire log), Phase-2 header-absent hard failure, and the forwarded-student success path. Declares `store? => false`, sets `devise.skip_trackable`, stamps the client id + origin claims + a machine `portal.auth_error` code on failures, and fails closed (never falls through to the mapped user when the header is present).

**Files affected**:
- `rails/lib/oidc_bearer_token_authenticatable.rb` — rewrite `authenticate!` + helpers
- `rails/spec/libs/bearer_token/oidc_bearer_token_authenticatable_spec.rb` — extend

**Estimated diff size**: ~180 lines

Rewritten strategy (key methods; `valid?`, `oidc_token_value`, `sanitize_log` unchanged):

```ruby
    # Token strategies must not serialize the acting identity into a session.
    def store?
      false
    end

    def authenticate!
      token = oidc_token_value
      payload = GoogleOidcVerifier.verify(token)

      oidc_client = Admin::OidcClient.find_by(sub: payload['sub'])
      return fail_oidc!('no OidcClient found', payload) unless oidc_client
      return fail_oidc!('inactive client', payload) unless oidc_client.active?

      stamp_common(oidc_client, payload)

      forwarded = forwarded_jwt_value

      # Opt-in gate: honor the forwarded-student override for a client that either
      # declares lifecycle capabilities OR requires the forwarded JWT. The two are
      # orthogonal - `requires_forwarded_jwt` is an identity choice ("act as the
      # forwarded student, no mapped-user fallback"), `capabilities` are the extra
      # lifecycle powers beyond a normal student. A future forwarded-identity client
      # with no elevated capabilities is valid (it acts as the student for ordinary
      # student-scoped operations only), so it must opt in on `requires_forwarded_jwt`
      # alone. Keying on it here also makes success!(nil) unreachable: a Phase-2
      # client has user_id=nil, and falling into success_as_mapped_user! would then
      # authenticate as nil. Any client with neither authenticates as its mapped user
      # and IGNORES the forwarded header (existing behavior, unchanged).
      unless oidc_client.capabilities.present? || oidc_client.requires_forwarded_jwt?
        return success_as_mapped_user!(oidc_client)
      end

      if forwarded.present?
        authenticate_forwarded_student!(oidc_client, forwarded)
      elsif oidc_client.requires_forwarded_jwt?
        # Phase 2: no mapped-user fallback.
        fail_auth!('forwarded_token_required', "header absent for client=#{oidc_client.id}")
      else
        # Phase 1: header absent -> legacy mapped user. Tripwire log so a rising
        # rate (a proxy stripping X-Forwarded-*) is observable.
        Rails.logger.info("OidcBearer: header-absent fallback to mapped user client=#{oidc_client.id}")
        success_as_mapped_user!(oidc_client)
      end
    rescue GoogleOidcVerifier::Error => e
      fail_auth!('oidc_token_invalid', "verification failed - #{sanitize_log(e.message)}")
    end

    private

    def authenticate_forwarded_student!(oidc_client, forwarded)
      result = ForwardedFirebaseToken.verify(forwarded)
      request.env['portal.auth_client_id']    = oidc_client.id
      request.env['portal.forwarded_student'] = true
      request.env['portal.origin_offering_id'] = result.origin_offering.id
      request.env['portal.origin_class_hash']  = result.origin_clazz.class_hash
      # Suppress Devise :trackable ONLY on the acting-as-student path (store? => false
      # does not stop the after_set_user trackable hook) so we never overwrite the
      # real student's sign-in tracking. The mapped-user path below intentionally
      # keeps today's behavior (harmless service-account bump) to preserve spring.
      request.env['devise.skip_trackable'] = true
      success!(result.user)
    rescue ForwardedFirebaseToken::Invalid => e
      # Never log the raw token; log the fact + reason only.
      fail_auth!('forwarded_token_invalid', "forwarded token invalid reason=#{e.reason} client=#{oidc_client.id}")
    end

    def success_as_mapped_user!(oidc_client)
      request.env['portal.auth_client_id'] = oidc_client.id
      success!(oidc_client.user)   # spring path unchanged: no skip_trackable
    end

    def stamp_common(oidc_client, payload)
      request.env['portal.auth_strategy'] = 'oidc_bearer_token'
      request.env['portal.auth_client']   = oidc_client.name   # display/logging only
      request.env['portal.auth_details']  = { sub: payload['sub'], email: payload['email'], aud: payload['aud'] }
    end

    def fail_oidc!(msg, payload)
      Rails.logger.warn("OidcBearer: authenticate! #{msg} for sub=#{payload['sub']} email=#{payload['email']}")
      fail_auth!('oidc_token_invalid', msg)
    end

    # Stamp a machine code for the controller ForwardedAuthGuard to render as
    # 401 + error_code, then fail (non-bang, matching the original strategy).
    # Fail-closed is enforced by the guard keying on portal.auth_error being
    # present, NOT by halting the chain, so non-bang fail is sufficient and
    # avoids the bang-authenticate/CustomFailure footgun under Devise's test shim.
    def fail_auth!(code, log_msg)
      request.env['portal.auth_error'] = code
      Rails.logger.warn("OidcBearer: #{log_msg} (error_code=#{code})")
      fail(:invalid_token)
    end

    def forwarded_jwt_value
      request.headers['X-Portal-Student-JWT'].presence
    end
```

Strategy spec additions (isolation pattern, per the existing spec — construct the strategy, stub `request`, call `authenticate!`):
- opted-in client + no forwarded header, `requires_forwarded_jwt=false`: `success!` with mapped user; `portal.auth_client_id` stamped; header-absent fallback logged; `devise.skip_trackable` **not** set (spring path unchanged).
- opted-in client + valid forwarded learner token: `success!` with the student; `portal.forwarded_student`, `origin_offering_id`, `origin_class_hash`, `auth_client_id` stamped; `devise.skip_trackable` set.
- opted-in client + invalid forwarded token (each `ForwardedFirebaseToken::Invalid` reason): `authenticate!` returns `:failure`; `portal.auth_error == 'forwarded_token_invalid'`; **no** mapped-user success.
- opted-in client + `requires_forwarded_jwt=true` + header absent: `authenticate!` returns `:failure`; `portal.auth_error == 'forwarded_token_required'`; **no** mapped-user success. Assert this for a `requires_forwarded_jwt=true` client with **empty** capabilities and `user_id=nil` too (the Phase-2 data state), proving the `|| requires_forwarded_jwt?` gate is exercised and `success!(nil)` is unreachable - it fails `forwarded_token_required`, never a 403 from a nil mapped user.
- **non**-opted-in client (no capabilities) + valid forwarded header: `success!` with **mapped user**; `portal.forwarded_student` not set (override ignored).
- OIDC failures (no client / inactive / verify raises): `authenticate!` returns `:failure`; `portal.auth_error == 'oidc_token_invalid'`.
- `store?` returns false.

**Observability (log-based, no in-repo metrics backend)**: the Phase-1 header-absent fallback and the present-but-invalid forwarded-token signals are emitted as structured `Rails.logger` lines (`info`/`warn`), mirroring the existing strategy's `sanitize_log` logging — the app has no StatsD/Prometheus backend to target. The proxy-stripping tripwire (alerting on a rising header-absent-but-OIDC-present rate in Phase 1) is therefore a **threshold/rate alert configured in ops tooling on the log stream**, not an in-app metric. The present-but-invalid line records the fact + failure reason only, never the raw forwarded JWT (a live act-as-student bearer credential).

---

### Distinguishable auth-error rendering (error_code + ForwardedAuthGuard)

**Summary**: Give `API::APIController#error` a top-level `error_code`, and add a `ForwardedAuthGuard` concern that forces the strategy chain and renders `401 + error_code` from `request.env['portal.auth_error']` before Pundit can turn a nil user into a 403. Include it on the two RIGSE-352 controllers only (`emails`/`oidc_send` is left unchanged per OQ2 — RIGSE-353 adds the reusable concern to `teacher_send`).

**Files affected**:
- `rails/app/controllers/api/api_controller.rb` — `error(message, status, details, error_code)` (positional trailing param; see the Ruby-3 keyword note below)
- `rails/app/controllers/concerns/forwarded_auth_guard.rb` — new concern
- `rails/app/controllers/api/v1/offerings_controller.rb` — include, scope to `update_student_metadata`
- `rails/app/controllers/api/v1/students_controller.rb` — include, scope to `add_to_class`
- specs (see testing step)

**Estimated diff size**: ~75 lines

`error` extension (add `error_code` as a **positional** trailing param, placed top-level):

```ruby
  def error(message, status = 400, details = nil, error_code = nil)
    error_body = {
      :success => false,
      :response_type => "ERROR",
      :message => message,
    }
    error_body[:error_code] = error_code if error_code
    error_body[:details] = details if details
    render :json => error_body, :status => status
  end
```

**Why positional, not keyword (`error_code:`)**: adding *any* keyword parameter to `error` would change Ruby 3 argument parsing for the existing hash-style callers `error(class_word: I18n.t(...))` (students_controller.rb:15,17) and `error(school_id: I18n.t(...))` (teachers_controller.rb:17,19). Today those pass a Hash as the positional `message` (the method has no keyword params, so a trailing `key: value` is collected as a positional Hash). Declaring `error_code:` would instead bind `class_word:`/`school_id:` as keywords and raise `ArgumentError: unknown keyword`. A trailing **positional** `error_code = nil` keeps the hash-as-message behavior intact (a method with no keyword params still treats `key: value` at the call site as a positional Hash), and the new callers pass it positionally as shown below.

Concern (note: `app/controllers/concerns` does not exist yet — create it; it is a Rails-default autoload path):

```ruby
module ForwardedAuthGuard
  extend ActiveSupport::Concern

  private

  # Force the Warden chain (lazy current_user) so the OIDC strategy can stamp
  # portal.auth_error, then render the distinguishable 401 before Pundit runs.
  # A no-op for non-OIDC requests (the strategy only stamps when it ran).
  def reject_forwarded_auth_error
    current_user
    code = request.env['portal.auth_error']
    return unless code
    error(auth_error_message(code), 401, nil, code)   # positional error_code (see note above)
  end

  def auth_error_message(code)
    case code
    when 'forwarded_token_invalid'  then 'Forwarded student token is invalid'
    when 'forwarded_token_required' then 'A forwarded student token is required'
    when 'oidc_token_invalid'       then 'OIDC service token is invalid'
    else 'Authentication failed'
    end
  end
end
```

Controllers include and scope with a `prepend_before_action` (must beat `require_api_user!`/`require_oidc_auth!` and Pundit):

```ruby
# offerings_controller.rb
class API::V1::OfferingsController < API::APIController
  include ForwardedAuthGuard
  prepend_before_action :reject_forwarded_auth_error, only: [:update_student_metadata]
  # ...
```

```ruby
# students_controller.rb
class API::V1::StudentsController < API::APIController
  include ForwardedAuthGuard
  prepend_before_action :reject_forwarded_auth_error, only: [:add_to_class]
  # ...
```

`emails_controller.rb` (`oidc_send`) is **not** modified by this story (OQ2). RIGSE-353 includes `ForwardedAuthGuard` on the new `teacher_send` action.

**Why `prepend_before_action` + `only:`**: it runs first (so `forwarded_token_invalid` renders a 401 instead of Pundit's 403), and scoping to the guarded action avoids forcing eager auth on unrelated actions on these controllers.

**Error-contract boundary (401 vs 403)**: `401 oidc_token_invalid` covers the three failures that occur **after** the strategy's `valid?` passes (a Google-issuer `Bearer` token) — Google verification failure, no matching `Admin::OidcClient`, and inactive client — each of which stamps `portal.auth_error`. An `Authorization` value that is **not** a Google OIDC token at all fails `valid?`, so the strategy never runs, never stamps `portal.auth_error`, and the request surfaces as the existing Pundit **403** (nil `current_user`). This is acceptable because report-service always sends a real Google OIDC service token, so the only OIDC-failure modes report-service can actually hit are the three that map to `401 oidc_token_invalid`.

---

### Authorization: action-scoped policy queries and per-operation access checks

**Summary**: Add `Portal::OfferingPolicy#update_student_metadata?` and `Portal::ClazzPolicy#add_to_class?` (each dispatches to a trusted forwarded-student branch when acting as the forwarded student, else the existing teacher/admin predicate), repoint the two controller `authorize` calls to them, and implement the per-operation checks (self-identity, origin vs open-only value constraint with boolean normalization, shared-teacher enroll rule, not-archived). Leaves the bare `update?`/`update_roster?` untouched so their sibling actions stay teacher/admin-only.

**Files affected**:
- `rails/app/policies/portal/offering_policy.rb`
- `rails/app/policies/portal/clazz_policy.rb`
- `rails/app/controllers/api/v1/offerings_controller.rb` — `authorize offering, :update_student_metadata?`
- `rails/app/controllers/api/v1/students_controller.rb` — `authorize portal_clazz, :add_to_class?`
- `rails/spec/policies/portal/offering_policy_spec.rb`, `.../clazz_policy_spec.rb`

**Estimated diff size**: ~205 lines

`Portal::OfferingPolicy` (add the action-scoped query + forwarded-student branch; `update?` unchanged):

```ruby
  def update_student_metadata?
    # A forwarded-student request is bound to student-scope EXCLUSIVELY: when
    # acting as the forwarded student we must NOT also fall through to the
    # teacher/admin branch. `current_user`'s portal roles are independent of the
    # forwarded identity, so a forwarded learner token minted for a user who is
    # also a class teacher / global admin / project-admin would otherwise satisfy
    # `class_teacher_or_admin?` and bypass every student-scoped guard below
    # (self-identity, origin, open-only), letting it lock/hide another student's
    # offering. Gate on the auth path, never on the user's roles.
    return forwarded_update_offering_state? if oidc_context.acting_as_forwarded_user?
    class_teacher_or_admin?
  end

  private

  def forwarded_update_offering_state?
    ctx = oidc_context
    return false unless ctx.capability?('update_offering_state')
    return false unless student? && class_student?          # current_user is a student in this offering's class
    return false unless target_user_is_acting_student?      # target user_id == current_user.id

    if record.id == ctx.origin_offering_id
      true                                                  # origin: lock / hide / open all allowed
    else
      open_only_write?                                      # non-origin: only unlock / make-visible
    end
  end

  def target_user_is_acting_student?
    @params.present? && @params[:user_id].to_s == user.id.to_s
  end

  # Non-origin offerings may only be opened (unlocked / made visible). Deny any
  # write that locks (locked=true) or hides (active=false). Also require at least
  # one of the permitted state keys: an empty write (neither locked nor active)
  # is not "opening" anything, and the controller upserts via find_or_create_by
  # BEFORE applying permit, so an empty request would otherwise materialize a
  # defaulted UserOfferingMetadata row (active:true, locked:false) on a non-origin
  # offering. Cast booleans so "true"/"1"/1 and JSON true are all caught.
  def open_only_write?
    return false unless @params.present?
    return false unless @params.key?(:locked) || @params.key?(:active)
    cast = ActiveModel::Type::Boolean.new
    locked = cast.cast(@params[:locked])
    active = cast.cast(@params[:active])
    !(locked == true || active == false)
  end
```

`Portal::ClazzPolicy` (add `add_to_class?`; `update_roster?` unchanged):

```ruby
  def add_to_class?
    # Same exclusivity as update_student_metadata?: a forwarded-student request
    # never also gets the teacher/admin `update_roster?` branch, so a forwarded
    # token minted for a user who is independently a class teacher / admin /
    # project-admin cannot enroll arbitrary students.
    return forwarded_enroll_student? if oidc_context.acting_as_forwarded_user?
    update_roster?
  end

  private

  def forwarded_enroll_student?
    ctx = oidc_context
    return false unless ctx.capability?('enroll_student')
    return false unless student?
    return false unless target_is_acting_student?   # enroll only yourself
    origin_clazz = ctx.origin_clazz
    return false unless origin_clazz
    return false if record.is_archived?
    (origin_clazz.teachers.to_a & record.teachers.to_a).any?   # any shared teacher (incl. co-teachers)
  end

  # add_to_class accepts user_id and/or student_id, and find_student_from_params
  # (students_controller.rb:272) prioritizes student_id over user_id. A naive
  # "user_id matches OR student_id matches" check is exploitable: a token for
  # student A could send user_id=A (satisfies the OR) plus student_id=B, and the
  # controller would enroll B (student_id wins). So require EVERY provided
  # identifier to resolve to the acting student, and require at least one present.
  # This is robust regardless of which param the controller prioritizes and keeps
  # the "enroll only ever adds the acting student themselves" safety property
  # intact. `show?` is not relied on for this (its admin/teacher/project-admin
  # clauses pass for a privileged acting-user).
  def target_is_acting_student?
    return false unless @params.present?
    checked = false
    if @params[:student_id].present?
      checked = true
      return false unless user.portal_student && @params[:student_id].to_s == user.portal_student.id.to_s
    end
    if @params[:user_id].present?
      checked = true
      return false unless @params[:user_id].to_s == user.id.to_s
    end
    checked   # deny when neither identifier was supplied
  end
```

Controllers:
```ruby
# offerings_controller.rb#update_student_metadata
    authorize offering, :update_student_metadata?
```
```ruby
# students_controller.rb#add_to_class
    authorize portal_clazz, :add_to_class?
```
The follow-on `authorize student, :show?` in `add_to_class` is **retained** as defense-in-depth, but it is **no longer the load-bearing identity guard**: `forwarded_enroll_student?` now explicitly binds the target to the acting student by requiring **every** provided identifier (`user_id` and/or `student_id`) to resolve to that student. This matters because `Portal::StudentPolicy#show?` also passes via `admin?`, teacher-of-record, or project-admin, so for a forwarded token whose user independently holds one of those roles, `show?` would not deny enrolling a *different* student. It must be "every provided identifier," not "any": because `find_student_from_params` prioritizes `student_id` over `user_id`, an "any-match" check would let `user_id=<self>` + `student_id=<other>` slip a different student past the policy while the controller enrolls that other student.

Policy specs (build the policy with a `PunditUserContext` whose `request.env` carries the stamps a successful/failed strategy would set — the same seam the strategy stamps; no live Warden needed):
- **OfferingPolicy**: origin-offering lock allowed with `update_offering_state`; denied without the capability; denied when `params[:user_id]` != acting student; teacher/admin path still allowed; open (`locked:false`/`active:true`) of a non-origin enrolled offering allowed; non-origin `locked:true` **and** non-origin `active:false` denied (string `"true"`/`"false"` and JSON `true`/`false` both), while the same writes on the origin offering allowed; non-origin offering in a class the student is not in denied (`class_student?` false). **Exclusivity + empty-write** (external-review round): a forwarded token whose acting user is *also* a class teacher/admin is still bound to student-scope (cannot modify another student's non-origin offering, cannot lock a non-origin offering) - i.e. `acting_as_forwarded_user?` takes the forwarded branch exclusively, never `class_teacher_or_admin?`; and a non-origin forwarded write with **only** `user_id` (no `active`/`locked` key) is **denied** (the `@params.key?` guard). Plus a scoping test: the bare `update?` (used by `offerings#update`) does **not** grant the forwarded-student branch.
- **ClazzPolicy**: enroll allowed with `enroll_student` when target shares any teacher (incl. co-teacher) and is not archived; denied on no shared teacher; denied on archived target; denied without the capability. **Exclusivity + target binding** (external-review round): a forwarded token whose acting user is *also* a teacher/admin of the target class is still bound to student-scope (takes the forwarded branch exclusively, not `update_roster?`), and enrolling a **different** student is denied **in the forwarded branch itself** via `target_is_acting_student?` - assert for a mismatched `user_id`, a mismatched `student_id`, **and the mixed case** `user_id=<acting student> + student_id=<other student>` (must be denied: `find_student_from_params` would enroll the `student_id`, so an any-match check would be a bypass). Also assert the consistent both-present case (`user_id` and `student_id` both the acting student) is allowed. These are asserted in the forwarded branch, not only via `StudentPolicy#show?`. Scoping test: `update_roster?` (used by `remove_from_class`) does **not** grant the forwarded-student branch.

---

### Optional O14: expose class_word on the offering serializer

**Summary**: Optional optimization (not a completion blocker). Add `class_word` to the `API::V1::Offering` show serializer so report-service resolves the origin class word in one `offerings/:id` read.

**Files affected**:
- `rails/app/models/api/v1/offering.rb` — attribute + assignment near clazz fields (offering.rb:57-60, 92-94)
- `rails/spec/models/api/v1/offering_spec.rb` — assert presence

**Estimated diff size**: ~10 lines

```ruby
  attribute :class_word, String
  # ...
    self.class_word = offering.clazz.class_word
```

---

### Phase-1 capability grant and Phase-2 flip (rake tasks)

**Summary**: Deliver the data steps as idempotent, environment-run rake tasks (the client's `sub` is environment-specific, so a hard-coded data migration is wrong). Phase-1 grants the existing client its three capabilities while leaving `user_id` set and `requires_forwarded_jwt=false`. Phase-2 nulls `user_id` and sets `requires_forwarded_jwt=true`. Both look the client up by `sub` (from `ENV`/argument).

**Mandatory rollout ordering (Phase-1 grant is release-critical, not optional)**: the `oidc:grant_forwarded_capabilities` task **must be run — and verified via `oidc:verify_forwarded_capabilities` — before REPORT-83 header-forwarding is enabled in each environment.** This is a hard sequencing obligation because the strategy's opt-in gate keys on `capabilities.present? || requires_forwarded_jwt?` (see the strategy step): an **un-granted** client (empty capabilities, `requires_forwarded_jwt=false`) falls through the gate and authenticates as its mapped user, **ignoring the forwarded header entirely**. So if report-service begins forwarding `X-Portal-Student-JWT` before the grant lands, the service client silently keeps authenticating as the over-privileged mapped admin instead of acting as the student — the exact over-privilege this story removes, defeated silently with no error. Requirements pin this: "the client must already hold its `capabilities` in Phase 1 for a header-present call to authorize" (requirements.md, Two-phase rollout), and the schema migration + capability grant "ship together." Treat the grant as part of the deploy, gated by the verify task, not as a later convenience.

**Files affected**:
- `rails/lib/tasks/oidc_forwarded_capabilities.rake` — new (grant, verify, and Phase-2 flip tasks)
- `rails/spec/libs/tasks/oidc_forwarded_capabilities_spec.rb` — optional task specs

**Estimated diff size**: ~85 lines

```ruby
namespace :oidc do
  # Phase 1: grant the service client its capabilities (mapped-user fallback preserved).
  # Usage: rake oidc:grant_forwarded_capabilities SUB=<google-sa-sub>
  task grant_forwarded_capabilities: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    # Grant by set union so a re-run never drops a capability added elsewhere
    # (keeps the task idempotent under future additions to this client's set).
    granted = (client.capabilities || []) | %w[enroll_student update_offering_state send_teacher_email]
    client.update!(capabilities: granted)
    puts "Granted capabilities to #{client.name} (id=#{client.id}); capabilities=#{client.capabilities.inspect} user_id=#{client.user_id} requires_forwarded_jwt=#{client.requires_forwarded_jwt}"
  end

  # Rollout gate: fail if the service client does not already hold the three
  # lifecycle capabilities. Run this (and require it to pass) BEFORE enabling
  # REPORT-83 header-forwarding in each environment - see the mandatory-ordering
  # note below. Exits non-zero so it can gate a deploy/runbook check.
  # Usage: rake oidc:verify_forwarded_capabilities SUB=<google-sa-sub>
  task verify_forwarded_capabilities: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    required = %w[enroll_student update_offering_state send_teacher_email]
    missing = required - (client.capabilities || [])
    if missing.any?
      abort "FAIL: #{client.name} (id=#{client.id}) is missing capabilities #{missing.inspect}; grant them before enabling REPORT-83 forwarding."
    end
    puts "OK: #{client.name} (id=#{client.id}) holds all required forwarded-student capabilities."
  end

  # Phase 2: remove the mapped-user fallback for good. Gated on report-service
  # forwarding the header in prod AND the notify step having moved off oidc_send.
  # Usage: rake oidc:require_forwarded_jwt SUB=<google-sa-sub>
  task require_forwarded_jwt: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    client.update!(requires_forwarded_jwt: true, user_id: nil)
    puts "Flipped #{client.name} (id=#{client.id}) to require forwarded JWT; user_id now nil"
  end
end
```

**Rollback caveat**: after Phase-2, re-imposing `NOT NULL` on `user_id` fails against the null row; a Phase-2 rollback must first repopulate `user_id` with the mapped user (re-run a grant of the id) before any schema rollback.

**Manual fallback**: because the admin form (previous step) now exposes `capabilities`, `requires_forwarded_jwt`, and `user_id`, both phases can also be applied by hand in the admin UI. The rake tasks are the recommended, auditable path — especially the Phase-2 flip, which must set `requires_forwarded_jwt=true` and `user_id=nil` together to pass the conditional user-presence validation.

**On the "is a deferred Phase-1 grant safe?" question**: only in the narrow sense that nothing crashes and spring behavior is preserved — an un-granted client authenticates as its mapped user via the opt-in gate rather than erroring. It is **not** safe against the story's actual goal: until the grant runs, a header-present call does **not** act as the student, so enabling REPORT-83 forwarding first silently preserves the over-privileged admin path (see the mandatory-ordering note above). "Deferrable without breakage" is not "deferrable without regressing the security objective." The grant must precede (and be verified before) forwarding is enabled.

---

### Acceptance / integration test coverage

**Summary**: The request/controller-level acceptance scenarios from requirements, written with the **mock-`current_user` + stamp-`request.env`** pattern (per the verified finding that the live Warden chain is not reliably exercisable in specs). Each test sets `request.env` to the state a real strategy outcome would produce, then asserts the controller/policy behavior.

**Files affected**:
- `rails/spec/controllers/api/v1/offerings_controller_spec.rb`
- `rails/spec/controllers/api/v1/students_controller_spec.rb`
- `rails/spec/controllers/api/v1/oidc_auth_spec.rb` (extend for the error contract)

**Estimated diff size**: ~200 lines

Pattern for the error-contract tests (stamp the strategy outcome, don't drive Warden):

```ruby
# forwarded_token_invalid => 401 with top-level error_code, not 403, not mapped user
it 'renders 401 forwarded_token_invalid' do
  allow(controller).to receive(:current_user).and_return(nil)
  request.env['portal.auth_error'] = 'forwarded_token_invalid'
  put :update_student_metadata, params: { id: offering.id, user_id: student_user.id, locked: true }
  expect(response.status).to eq(401)
  body = JSON.parse(response.body)
  expect(body['error_code']).to eq('forwarded_token_invalid')   # top-level, not nested
  expect(body['success']).to eq(false)
end
```

Pattern for the acts-as-student happy path (stamp the override the strategy would produce):

```ruby
it 'locks the origin offering acting as the student' do
  allow(controller).to receive(:current_user).and_return(student_user)
  request.env['portal.auth_strategy']    = 'oidc_bearer_token'
  request.env['portal.auth_client_id']   = forwarded_client.id       # opted-in, has update_offering_state
  request.env['portal.forwarded_student'] = true
  request.env['portal.origin_offering_id'] = offering.id
  request.env['portal.origin_class_hash']  = offering.clazz.class_hash
  put :update_student_metadata, params: { id: offering.id, user_id: student_user.id, locked: true }
  expect(response.status).to eq(200)
end
```

Scenario coverage (grouped by requirements' "Acceptance test scenarios"):
- **Error contract** (offerings/students specs): `forwarded_token_invalid`, `forwarded_token_required`, `oidc_token_invalid` each render `401` with the exact **top-level** `error_code`, distinct bodies, never a 403, never mapped-user fall-through. Assert the exact JSON path. (`oidc_send` is unchanged per OQ2, so its error rendering is not part of this story's contract tests.)
- **Acts-as-student** (offerings/students specs): origin lock happy path; open-target happy path; acting-as-A modifying B (`params[:user_id]` != current_user) denied (403 via policy); enrolling a **different** student denied via `student :show?`/`owner?`.
- **Direct-call denial — AC3** (offerings/students specs, **request/controller level**): a request carrying `X-Portal-Student-JWT` but **no** OIDC `Authorization` header must be rejected and must mutate nothing. Assert for **both** `update_student_metadata` (no `UserOfferingMetadata` upsert) and `add_to_class` (no `StudentClazz` created), with `current_user` nil → the existing Pundit **403**. This must be a controller/request test, **not** a strategy unit test: the OIDC strategy is selected only from the `Authorization` header (`oidc_token_value`/`valid?`), so a Firebase-header-only request never invokes the strategy at all — a strategy spec cannot exercise or prove this path. This is the half of "both-tokens-required" that operationalizes AC3 ("a student cannot perform these lifecycle operations by calling the portal directly").
- **Opt-in gate, tracking-neutrality, both-tokens-present (valid OIDC + valid forwarded → acts as student), phase matrix, non-learner, expiry boundary, platform_id mismatch**: covered at the strategy/`ForwardedFirebaseToken` unit level (previous steps), since those are auth-layer behaviors the controller specs cannot drive through live Warden. Note the **Firebase-header-only / no-OIDC** half of both-tokens-required is the deliberate exception — it lives at the controller level (the direct-call-denial bullet above), because the strategy is never selected without an `Authorization` header.
- **Capability + migration** (`oidc_client_spec.rb`): both Phase-1 and Phase-2 record states; capability validation.
- **Authorization** (policy specs): as enumerated in the authorization step.

**Testing-strategy note**: The strategy-level scenarios (opt-in gate, skip_trackable, both-tokens, phase behaviors, non-learner, expiry) live in the strategy + `ForwardedFirebaseToken` specs (isolation), and the controller specs cover only what a stamped `request.env` + `current_user` can express (error rendering, policy outcomes). This split is deliberate and matches the existing `oidc_auth_spec.rb` approach; do not attempt a full-middleware request spec for the override (it is not reliably reproducible — see the research summary).

**Tracking-neutrality assertion level**: the requirements' "acting student's Devise tracking fields unchanged" scenario is asserted at the **mechanism** level — `request.env['devise.skip_trackable'] == true` on the forwarded path — not by comparing actual `sign_in_count`/`last_sign_in_*` values. The field-level outcome rests on Devise's own tested handling of `devise.skip_trackable` (devise-4.9.4 `hooks/trackable.rb`); a full field-level assertion is intentionally not attempted because it needs the live Warden `set_user`/`after_set_user` hook, which the research finding showed is not reliably reproducible in specs. (A plain `success!(mapped_user)` on the mapped path, by contrast, is left to fire trackable as today.)

---

## Open Questions

<!-- Implementation-focused questions only. Requirements questions go in requirements.md. -->

### RESOLVED: Capability grant as rake tasks vs a data migration
**Context**: The one client's `sub` is environment-specific (different Google service-account per env), so a data migration with a hard-coded `sub`/`user_id` is brittle. The record is also **created by hand via the admin CRUD UI**, not seeded in code, so it already exists per-env. Verified property: with the opt-in gate, a client whose `capabilities` are unset authenticates as the mapped user (spring behavior), so a deferred Phase-1 grant does not crash and does not break spring — but it is **not** a no-op for the security goal: until the grant lands, a header-present call keeps acting as the over-privileged mapped admin instead of the student, so the grant is a **release-critical, ordered step that must run (and be verified) before REPORT-83 forwarding is enabled**, not a free-floating activation switch (see the mandatory-ordering note in the rake-task step). The Phase-2 flip is separately gated on cross-repo readiness, so it can never auto-run on deploy — it must be a separately-timed manual step regardless.
**Options considered**:
- A) **Rake tasks** (this plan): explicit, env-parameterized, re-runnable, atomic Phase-2 flip (`requires_forwarded_jwt=true` + `user_id=nil` in one validation-passing `update!`), and keeps the Phase-1/Phase-2 separation symmetric.
- B) A Phase-1 **data migration** that finds the client by an ENV-provided sub and grants capabilities: runs automatically on deploy, but couples a data change to the schema deploy, needs the sub at migrate time, and still leaves Phase-2 as a task (splitting the two phases across mechanisms).
- C) Admin UI only: zero new code (the form now exposes these fields), but not scriptable/repeatable, easy to forget, and the Phase-2 flip by hand (blank `user_id` + check the box in one save, in validation-passing order) is error-prone.

**Decision**: **A** (rake tasks). Only option that treats both phases symmetrically, makes the Phase-2 flip atomic/validation-safe, and avoids the migrate-time `sub` coupling. Note added to the rake-task step: because the admin form now exposes `capabilities`/`requires_forwarded_jwt`/`user_id`, option C remains available as a manual fallback, but the rake tasks are the recommended, auditable path — especially for the timed Phase-2 flip.

### RESOLVED: Scope of ForwardedAuthGuard on oidc_send
**Context**: `oidc_send` (RIGSE-353 replaces it with `teacher_send`) is left unchanged by this story. Verified: (1) including the guard breaks **no** existing `oidc_send` test — the guard renders only when `portal.auth_error` is stamped, which no email spec sets, so it is a no-op on every current case; this is a scope decision, not a technical one. (2) `oidc_send` is OIDC-only and report-service's notify step migrates **off** it to `teacher_send` before the override goes live, so there is no remaining consumer for an `error_code` contract there. (3) Requirements' Out of Scope explicitly says `oidc_send` "is not modified or removed here"; adding the guard would change its auth-failure rendering.
**Options considered**:
- A) **Include on `oidc_send`**: uniform error contract across the forwarded-student surface, no test breakage — but modifies an explicitly out-of-scope endpoint for a contract with no remaining consumer there.
- B) **Defer** — guard only the two endpoints RIGSE-352 owns (`update_student_metadata`, `add_to_class`); RIGSE-353 includes the reusable concern on `teacher_send`. Keeps `oidc_send` literally unchanged.

**Decision**: **B** (defer). The requirements explicitly mark `oidc_send` unchanged/out-of-scope and report-service's forwarded-student flow will not call it, so there is no consumer for an error contract there. RIGSE-353's `teacher_send` is the natural home for the guard; the concern being reusable makes that a one-liner. The "Distinguishable auth-error rendering" step is updated to include `ForwardedAuthGuard` on **offerings** and **students** only, not **emails**.

### RESOLVED: Step grouping / commit boundaries
**Context**: The plan lists nine implementation steps plus tests. Verified there are **no forward code dependencies** among them (3 before 5; 1 before 4/5/9; 4 before 7; policies (7) read the stamps the strategy (5) sets). The one true ordering constraint is **behavioral, not a code dependency**: the auth-error-rendering step (`error_code` + `ForwardedAuthGuard`) must ship **before or with** the strategy rewrite, because the strategy stamps `portal.auth_error` and the guard is what turns that into the required `401 + error_code` (see the Decision). Every step is independently reviewable and well under ~500 lines.
**Options considered**:
- A) Keep the steps as-is (each a focused commit). Migration/UI/auth/policy reviews stay separable; O14 stays its own tiny commit — a clean drop point since it is the one optional piece.
- B) Merge admin-CRUD into the model step and O14 into the policy/tests step (fewer, larger commits), but bundles schema-safety review with UI review and makes the optional O14 no longer cleanly droppable.

**Decision**: **A** (keep the focused commits). Each is a coherent, independently-reviewable unit; sizes are small; and keeping O14 standalone preserves it as a droppable optional. **Review/merge ordering to respect** (so the branch is never in a state where the strategy stamps `portal.auth_error` but no guard renders it):

- **The auth-error-rendering step (`error_code` + `ForwardedAuthGuard`) must land before — or in the same commit/deploy unit as — the strategy rewrite.** This is the reverse of the earlier draft, which had it backwards. The guard is a safe no-op until the strategy exists (it renders only when `portal.auth_error` is stamped, and nothing stamps it before the rewrite), so landing it first cannot regress anything. Landing the strategy **first** would open a window where an invalid forwarded/OIDC request stamps `portal.auth_error`, nulls `current_user`, and falls through to a Pundit **403** instead of the required `401 + error_code` — exactly the state this ordering note exists to prevent. Prefer combining the two into one commit if the reviewer would rather not split them.
- The context step (`OidcAuthContext`) and the strategy rewrite must both land before the policy step (7).

## Self-Review

<!-- Phase 3 multi-perspective review of the implementation plan (and its interaction with requirements). Each item was checked against the current source before being written. -->

### Security Engineer

#### RESOLVED: `succeed!` sets `devise.skip_trackable` on the mapped-user path too, changing spring behavior
`succeed!(user)` unconditionally set `request.env['devise.skip_trackable'] = true` and was called by both the forwarded-student path (correct) and the mapped-user path (spring). Today the fixed mapped-user `success!` fires `:trackable` harmlessly; suppressing it deviated from AC4 (spring preserved). **Fix applied**: removed the shared `succeed!`; `devise.skip_trackable` is set only inside `authenticate_forwarded_student!`, and `success_as_mapped_user!` calls plain `success!(oidc_client.user)`. Strategy-spec bullet updated to assert `skip_trackable` is **not** set on the mapped-user path.

### Senior Rails/Devise Engineer

#### RESOLVED: Use non-bang `fail` (as the original strategy), not `fail!`
`fail_auth!` called `fail!(:invalid_token)` (halt). Fail-closed is enforced by the controller `ForwardedAuthGuard` keying on `portal.auth_error` being present, so halting the chain is unnecessary, and `fail!` diverged from the proven original + existing unit tests and risks the bang-authenticate/`CustomFailure` footgun (the throwaway research reproduced a `CustomFailure` "Cannot redirect to nil" on a controller-spec path). **Fix applied**: `fail_auth!` now stamps `portal.auth_error`, logs, then `fail(:invalid_token)` (non-bang), with a comment that the guard enforces fail-closed. Strategy-spec bullets updated to assert `authenticate!` returns `:failure`.

#### RESOLVED: Drop the `capabilities` getter override; nil-guard at use sites instead
The plan overrode `def capabilities; self[:capabilities] ||= []; end`, which mutates on read (assigns `[]` when nil) and can mark the record dirty. **Fix applied**: removed the getter override; `capability?` uses `(capabilities || []).include?(...)` and the membership validation uses `(capabilities || []) - CAPABILITIES.keys`; the strategy's opt-in gate keeps `capabilities.present?` (nil-safe). Non-mutating, no `super`-through-`serialize` dependency. Model-spec bullet updated.

### QA Engineer

#### RESOLVED: The "tracking fields unchanged" scenario is a mechanism assertion, not an outcome assertion
Per the research finding, the real Warden `set_user`/trackable hook is not reliably reproducible in specs, so the scenario can only be asserted at the mechanism level. **Fix applied**: added a "Tracking-neutrality assertion level" note to the testing step stating the scenario is asserted as `request.env['devise.skip_trackable'] == true` on the forwarded path, with the field-level outcome resting on Devise's tested handling of that flag; a brittle full-middleware field assertion is intentionally not attempted.

### API-Contract / Integration

#### RESOLVED: Document the 401-vs-403 boundary for a non-Google Bearer token
**Fix applied**: added an "Error-contract boundary (401 vs 403)" note to the rendering step: `401 oidc_token_invalid` covers the three post-`valid?` failures (Google verification failure, no matching client, inactive client); an `Authorization` value that is not a Google OIDC token at all fails `valid?`, the strategy never runs, and the request surfaces as the existing Pundit `403` — acceptable because report-service always sends a real Google OIDC service token.

### Release Engineer

#### RESOLVED: Clarify the Phase-1 tripwire is log-based (no in-repo metrics backend)
**Fix applied**: added an "Observability (log-based, no in-repo metrics backend)" note to the strategy step: the fallback and present-but-invalid signals are structured `Rails.logger` lines (no StatsD/Prometheus in-repo), the proxy-stripping tripwire is a rate alert configured in ops tooling on the log stream, and the present-but-invalid line never logs the raw forwarded JWT.

---

## External Review (2026-07-22)

<!-- Findings from an external development review (Senior/Security/QA). Both verified against current source and applied to the Authorization step. -->

### Security Engineer

#### RESOLVED: Forwarded-student requests could still take the privileged teacher/admin branch (HIGH)
The proposed policies used `class_teacher_or_admin? || forwarded_update_offering_state?` and `update_roster? || forwarded_enroll_student?`. Because `current_user`'s portal roles are independent of the forwarded identity, a forwarded learner token minted for a user who is *also* a class teacher / global admin / project-admin would satisfy the first (teacher/admin) branch and bypass every student-scoped guard (self-identity, origin, open-only, shared-teacher), letting it lock/hide or enroll *other* students. `Portal::StudentPolicy#show?` (the follow-on check in `add_to_class`) has the same weakness: it passes via `admin?`/teacher-of-record/project-admin, so it is not a reliable identity guard for such a user. **Fix applied**: both action-scoped queries now dispatch to the forwarded branch **exclusively** when `oidc_context.acting_as_forwarded_user?` (`return forwarded_… if …; else the teacher/admin predicate`), never OR-ing the two. Added an explicit `target_is_acting_student?` check inside `forwarded_enroll_student?` binding the enrolled student to the acting student on **both** `user_id` and `student_id` (matching `find_student_from_params`), so `StudentPolicy#show?` is no longer load-bearing. Policy-spec bullets updated to assert a dual-role forwarded token is still student-scoped, and that enrolling a different student (mismatched `user_id` or `student_id`) is denied in the forwarded branch itself.

### Senior Engineer

#### RESOLVED: Non-origin "open-only" authorization allowed empty-metadata writes (MEDIUM)
`open_only_write?` returned true when neither `locked` nor `active` was supplied (both casts are `nil`, and the predicate only denied `locked==true`/`active==false`). Because the controller calls `UserOfferingMetadata.find_or_create_by` **before** `permit(:active, :locked)`, and the table defaults to `active:true, locked:false`, an empty forwarded request (only `user_id`) would still materialize a metadata row for a non-origin offering. **Fix applied**: `open_only_write?` now requires at least one permitted state key (`return false unless @params.key?(:locked) || @params.key?(:active)`) before applying the lock/hide denial. Policy-spec bullet added: a forwarded non-origin request with only `user_id` and no `active`/`locked` is denied and creates no `UserOfferingMetadata` row.

### Terminology

#### RESOLVED: "pipeline" collides with report-service job terminology
"pipeline" is report-service's own term for its job/processing pipeline in the portal, so using it to name the portal-side auth mechanism (policy branches, capabilities, the service client, error handling) was confusing. **Fix applied**: purged "pipeline" from the spec. Portal-side coinage now uses the feature's established `forwarded` prefix (`forwarded_update_offering_state?`, `forwarded_enroll_student?`, `reject_forwarded_auth_error`, `oidc:grant_forwarded_capabilities` / `verify_forwarded_capabilities`, `oidc_forwarded_capabilities.rake`, "forwarded-student branch"); genuine references to report-service's system now say "report-service". Spec title and folder renamed to Forwarded-Student Portal Auth / `RIGSE-352-forwarded-student-portal-auth`.

### API-Contract / Ruby (final broad external review, 2026-07-22)

#### RESOLVED: `error(..., error_code:)` keyword param broke existing hash-style `error` callers (HIGH)
The draft extended `API::APIController#error` as `def error(message, status = 400, details = nil, error_code: nil)` (a **keyword** param). Verified against source: `error` today has no keyword params, so the existing callers `error(class_word: I18n.t(...))` (students_controller.rb:15,17) and `error(school_id: I18n.t(...))` (teachers_controller.rb:17,19) pass a Hash as the positional `message`. Declaring any keyword param flips Ruby 3 parsing so `class_word:`/`school_id:` bind as keywords and raise `ArgumentError: unknown keyword` (and `message` goes missing) - breaking student/teacher registration error rendering. **Fix applied**: `error_code` is now a **positional** trailing param (`def error(message, status = 400, details = nil, error_code = nil)`); a method with no keyword params still treats call-site `key: value` as a positional Hash, so the hash-style callers keep working. The `ForwardedAuthGuard` call site now passes it positionally (`error(auth_error_message(code), 401, nil, code)`), and an inline note explains the constraint. Regression guard: add/confirm a spec that `error(class_word: "x")` still renders (the two registration paths already exercise it).

### Security Engineer (focused authz self-review of the applied fix)

#### RESOLVED: `target_is_acting_student?` any-match form was itself an enroll-anyone bypass (HIGH)
Found while self-reviewing the HIGH fix above. The first draft of the new enroll target check returned true on the **first** matching identifier (`user_id` matches **OR** `student_id` matches) - which is exactly the reviewer's suggested `params[:user_id] == current_user.id || params[:student_id] == current_user.portal_student.id` form. But `find_student_from_params` (students_controller.rb:272) resolves `student_id` **before** `user_id`, so the controller acts on `student_id` when both are present. A forwarded token for student A could therefore send `user_id=<A>` (satisfying the OR) plus `student_id=<B>`, pass the policy, and have the controller enroll **B** into a shared-teacher class - defeating the "enroll only ever adds the acting student themselves" safety property that the accepted-residual-risk analysis (requirements Per-operation access checks) explicitly leans on. **Fix applied**: `target_is_acting_student?` now requires **every** provided identifier to resolve to the acting student (and at least one present), robust regardless of which param the controller prioritizes. Added the mixed-param (`user_id=<self>` + `student_id=<other>`) deny case and the consistent-both-present allow case to the ClazzPolicy and request-level spec bullets.

---

<!-- FILL IN during Phase 5 finalization: keep or collapse this Self-Review as a decision log. -->

## Implementation Notes (during build)

Two low-impact fidelity notes recorded while implementing, neither requiring a code change beyond what the plan already specified:

- **`serialize :capabilities, type: Array` coerces a NULL column to `[]` on read.** In this Rails version an existing pre-migration client reads `capabilities == []`, not `nil`. The plan's nil-safe predicate (`(capabilities || [])`) and the form's `capability?` use are therefore defensively redundant but still correct and were kept as-is; the opt-in gate's `capabilities.present?` is `false` on `[]` exactly as intended. The model spec asserts the NULL-column case via `update_column(:capabilities, nil)` and confirms `capability?` returns false without raising.
- **`oidc_auth_spec.rb` was extended with forwarded-path integration cases (not error-contract rendering).** `API::V1::JwtController` (that spec's subject) does not include `ForwardedAuthGuard`, so the `401 + error_code` render contract is not exercisable there; it is covered at the controller level in the offerings/students specs as the testing step's scenario bullets state. The `oidc_auth_spec` extension instead drives the strategy through its integration harness for the forwarded-student happy path and asserts `portal.auth_error` is stamped on an invalid forwarded token.

