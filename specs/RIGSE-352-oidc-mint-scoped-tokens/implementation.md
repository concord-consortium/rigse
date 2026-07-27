# Implementation Plan: RIGSE-352 OIDC-Minted Scoped Portal Tokens

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-352
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

> All `D-` and `Q-` references (`D1-D11`, `Q1-Q4`) are defined in [requirements.md](requirements.md).
>
> **Base branch:** `master`. Start clean from master and re-add only the survivors below; do **not**
> branch from `RIGSE-352-add-oidc-use-override`. That branch is the *source* for the survivors (their
> implementation code is inlined below; the survivor spec files are pulled from it).

## Baseline: what is already on `master` (keep as-is)

Verified via `git diff master...HEAD` on the old branch:

- `rails/app/models/admin/oidc_client.rb` — on master (the old branch extends it; see "Rework"). Model +
  `admin_oidc_clients` table already exist.
- `rails/lib/oidc_bearer_token_authenticatable.rb` — on master in its mapped-user form (the old branch
  adds a forwarded-student path, which we drop). Master's strategy maps an OIDC client to its user and
  `success!`es as that user. That mapped-user behavior authenticates the mint call.
- `rails/app/controllers/api/v1/emails_controller.rb` — on master, untouched by 352. `oidc_send` stays;
  the new teacher-email action is separate (portal-authed).
- `rails/app/controllers/api/v1/jwt_controller.rb` — on master. The mint does **not** live here (Q4); it
  gets its own `API::V1::OidcMintController`. `jwt_controller`'s only change is the behavior-preserving
  claim-builder extraction.

---

## Implementation Plan

### Carry over the Firebase-decode survivors

**Summary**: Copy the Firebase-token decode primitive and its verifier from the old branch onto master.
These are new files the old 352 branch introduced that this design keeps unchanged; nothing depends on
the dropped machinery.

**Files affected**:
- `rails/lib/signed_jwt.rb` — ADD `decode_firebase_token_by_iss` and `verify_against_any` to master's
  `SignedJwt`.
- `rails/lib/forwarded_firebase_token.rb` — NEW, copy verbatim (self-contained).
- `rails/spec/libs/signed_jwt_spec.rb`, `rails/spec/libs/forwarded_firebase_token_spec.rb` — carry the
  survivor specs.

**Estimated diff size**: ~120 lines.

Add to `SignedJwt`:

```ruby
# Verify a forwarded Firebase custom token, selecting the RSA key from the
# token's iss (= FirebaseApp#client_email) rather than a caller-supplied app
# name. Signature and exp are enforced with zero clock skew. Returns
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

  app, decoded = verify_against_any(token, apps)
  raise SignedJwt::Error.new("Signature did not verify for iss=#{iss}") unless app
  {data: decoded[0], header: decoded[1], app: app}
end

def self.verify_against_any(token, apps)
  apps.each do |app|
    begin
      rsa = OpenSSL::PKey::RSA.new(app.private_key)
      decoded = JWT.decode(token, rsa, true, {algorithm: self.rsa_algorithm})
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

New `rails/lib/forwarded_firebase_token.rb` (copy verbatim):

```ruby
class ForwardedFirebaseToken
  class Invalid < StandardError
    attr_reader :reason
    def initialize(reason)
      @reason = reason
      super(reason.to_s)
    end
  end

  Result = Struct.new(:user, :origin_offering, :origin_clazz, keyword_init: true)

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
    decoded = decode!
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
    raise Invalid.new(decode_failure_reason(e.message))
  end

  def decode_failure_reason(message)
    case message
    when /expired/i        then :expired
    when /has no iss/i     then :no_iss
    when /No FirebaseApp/i then :app_not_found
    when /Undecodable/i    then :undecodable
    else :signature
    end
  end
end
```

The `:expired` reason is what D4 requires the mint to surface distinctly.

---

### Keep the `class_word` offering serializer field

**Summary**: Fill in the one class attribute the `API::V1::Offering` serializer was missing, so
REPORT-79 resolves the student's origin class word in one portal call instead of two. No new endpoint,
policy, or security surface.

**Files affected**:
- `rails/app/models/api/v1/offering.rb` — two lines.
- `rails/spec/models/api/v1/offering_spec.rb` — carry the spec.

**Estimated diff size**: ~10 lines.

```ruby
attribute :class_word, String                    # beside the existing :clazz / :clazz_hash / :clazz_id

self.class_word = offering.clazz.class_word      # in the same block as self.clazz = offering.clazz.name
```

The serializer already exposes `clazz`, `clazz_hash`, `clazz_id`, `clazz_info_url` and
`clazz_is_archived`; this exposes a class word to a caller already authorized to read that offering (who
could fetch it in one extra call regardless).

---

### Rework the OIDC client: one boolean flag; revert the strategy; drop the forwarded machinery

**Summary**: Collapse the old branch's capability array to a single fail-closed boolean, revert the OIDC
bearer strategy to master's mapped-user form, and delete the forwarded-auth files. Master's
`admin_oidc_clients` table has **no `capabilities` column** (`name, sub, email, user_id, active` only);
the serialized array, `CAPABILITIES`, `capability?`, `capabilities_are_recognized` and
`requires_forwarded_jwt` were all introduced by the old branch, so collapsing removes nothing on master.

**Files affected**:
- `db/migrate/XXXXXXXX_add_can_mint_scoped_tokens_to_admin_oidc_clients.rb` — NEW (the **only** schema
  change in the story).
- `rails/app/models/admin/oidc_client.rb` — master's model + the flag.
- `rails/app/views/admin/oidc_clients/_form.html.haml` — single checkbox instead of a capability
  multi-select.
- `rails/lib/oidc_bearer_token_authenticatable.rb` — revert to master's mapped-user form.
- rollout rake task — set the flag on the one client (much smaller than `oidc_forwarded_capabilities.rake`).
- **Drop** (do not carry from the old branch): `rails/lib/oidc_auth_context.rb` (+ spec);
  `rails/app/controllers/concerns/forwarded_auth_guard.rb`; `application_policy.rb` `oidc_context` helper;
  `clazz_policy.rb` forwarded branch (`forwarded_enroll_student?`, `target_is_acting_student?`,
  `add_to_class?` override); `offering_policy.rb` forwarded branch (`forwarded_update_offering_state?`,
  `open_only_write?`, `update_student_metadata?` override); `offerings_controller.rb` /
  `students_controller.rb` `ForwardedAuthGuard` wiring; `api_controller.rb#error` `error_code` param
  (unless reused); the RIGSE-353 `oidc_teacher_send` design.

**Estimated diff size**: ~80 lines net (mostly deletions).

```ruby
# migration
add_column :admin_oidc_clients, :can_mint_scoped_tokens, :boolean, default: false, null: false
```

```ruby
class Admin::OidcClient < ApplicationRecord
  self.table_name = 'admin_oidc_clients'

  belongs_to :user

  validates :name, presence: true
  validates :sub, presence: true, uniqueness: true
  validates :user, presence: true   # unconditional again: requires_forwarded_jwt is gone

  scope :active,        -> { where(active: true) }
  scope :token_minters, -> { where(can_mint_scoped_tokens: true) }
end
```

Notes:
- `default: false, null: false` denies every existing client until explicitly enabled (the fail-closed
  behavior D1 depends on).
- `validates :user, presence: true` is unconditional again (the old branch made it conditional on
  `requires_forwarded_jwt?`). Every client has a mapped user, which the mint authenticates as (a
  non-privileged service user per D1).
- Revert `oidc_bearer_token_authenticatable.rb` to master: drop `authenticate_forwarded_student!` and the
  `portal.forwarded_student` / `portal.origin_*` env stamping. The mint client authenticates as its
  mapped (non-admin) service user; the mint action checks the flag.

---

### Add the request-scoped audit marker (`Current`) and propagate it (D5 + D9 propagation)

**Summary**: Add an ambient, request-scoped carrier for the audit marker, set it in both token-decode
paths, stamp `request.env` for the log subscriber, propagate it at the `create_portal_token` choke point,
and emit it in the auth logs. Without the log-subscriber change nothing is logged and D5's control — which
D2 depends on — does not exist. **This step and the `jwt_controller` guard step must ship together**
(propagation without the guard denies nothing; the guard without propagation has no marker to check).

**Files affected**:
- `rails/app/models/current.rb` — NEW.
- `rails/lib/jwt_bearer_token_authenticatable.rb` — set `Current` + `request.env` (Warden path).
- `rails/app/controllers/api/api_controller.rb` — set `Current` + `request.env` in `check_for_auth_token`
  (the independent decode path).
- `rails/lib/signed_jwt.rb` — propagate in `create_portal_token`.
- `rails/config/initializers/auth_log_subscriber.rb` — emit `minted_via` / `minted_for`.

**Estimated diff size**: ~40 lines.

```ruby
# app/models/current.rb  (ActiveSupport::CurrentAttributes; Rails 8.0.1, no gem, auto-resets per request)
class Current < ActiveSupport::CurrentAttributes
  attribute :minted_via_oidc_client_id, :minted_for
end
```

Set it in **both** decode paths (using only one leaves a bypass):

```ruby
# 1. rails/lib/jwt_bearer_token_authenticatable.rb — the Warden path, alongside the existing
#    request.env['portal.auth_strategy'] = 'jwt_bearer_token'
data = decoded_token[:data]
Current.minted_via_oidc_client_id = data['minted_via_oidc_client_id']
Current.minted_for                = data['minted_for']
request.env['portal.minted_via_oidc_client_id'] = data['minted_via_oidc_client_id']
request.env['portal.minted_for']                = data['minted_for']
```

```ruby
# 2. rails/app/controllers/api/api_controller.rb#check_for_auth_token — the independent path, in the
#    branch that decodes a portal token. jwt_controller uses this instead of trusting Warden, so a
#    request with an existing session can satisfy current_user without the bearer strategy running.
#    Set the same Current + request.env pairs here.
```

The endpoints the pipeline actually calls (`update_student_metadata`, `add_to_class`,
`send_class_teachers`) go through path 1 only (`check_for_auth_token` is called from just
`jwt_controller.rb:87` and `api_controller.rb:129`). Path 1 makes downstream request logging work; path
2 makes the D9 guard sound.

Two consumers of the marker, hence both `Current` and `request.env`:
- `Current` — for `create_portal_token` propagation and the `AccessGrant` refusal (neither has the
  request).
- `request.env` — for the auth log subscriber (how the marker reaches the logs).

```ruby
# config/initializers/auth_log_subscriber.rb, alongside the existing additions
additions << "minted_via=#{req.env['portal.minted_via_oidc_client_id']}" if req.env['portal.minted_via_oidc_client_id']
additions << "minted_for=#{req.env['portal.minted_for']}"                if req.env['portal.minted_for']
```

Propagate when signing:

```ruby
# rails/lib/signed_jwt.rb#create_portal_token, before the merge
claims = claims.dup
claims[:minted_via_oidc_client_id] ||= Current.minted_via_oidc_client_id if Current.minted_via_oidc_client_id
claims[:minted_for]                ||= Current.minted_for                if Current.minted_for
```

**Use `||=`, not a blind merge.** The existing line is
`payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }`, which raises on
duplicates. The mint sets the marker explicitly at origin, so re-adding it unconditionally makes every
mint call fail. Never log the token itself (D4).

---

### Extract the shared portal-token claims builder (behavior-preserving refactor)

**Summary**: The mint lives in its own controller (Q4), so the guard against claim drift is a shared
builder, not shared controller code. Extract a PORO that owns the claim *shapes* currently inlined in
`jwt_controller#portal` (lines 189-219) and the signing call, and have both `JwtController#portal` and
`OidcMintController#create` use it. Keep it behavior-preserving: `JwtController#portal`'s emitted claims
and TTL must be byte-identical before and after (existing jwt specs pass untouched).

**Files affected**:
- `rails/lib/portal_token_claims.rb` — NEW PORO.
- `rails/app/controllers/api/v1/jwt_controller.rb` — call the builder from `portal`.

**Estimated diff size**: ~90 lines (mostly moved code).

Share (these are what would otherwise drift):
- The **learner** claim shape: `{domain, user_type: "learner", user_id, learner_id, class_info_url, offering_id}`.
- The **teacher** claim shape: `{domain, user_type: "teacher", user_id, teacher_id}`.
- The signing call `SignedJwt::create_portal_token(user, claims, ttl)`.
- `add_admin_claims` **is** shared and runs for both callers (D8 withdrawn): a minted token is a normal
  portal token for that teacher, so its claims match what `jwt_controller#portal` emits for the same user.

Deliberately do **not** share, and keep out of the mint's reach:
- `can_access_user` — the D1 bypass. Must remain private to `JwtController`, never callable from the mint.
- `handle_initial_auth` — caller-as-subject, the inverse of the mint's model.
- The class-level `rescue_from StandardError, with: :error_400`.

The builder needs **no parameters at all** (both the `admin_claims` switch, D8, and the TTL argument, D4,
are gone). A minted token differs from `jwt_controller#portal`'s output for the same teacher only by its
audit claim.

---

### Add the mint action (New work A)

**Summary**: The dedicated mint controller. Authenticates via the OIDC bearer strategy + the
`can_mint_scoped_tokens` flag, verifies the forwarded Firebase token, resolves the subject/scope (learner
or least-privileged teacher, with the cross-class shared-teacher rule), builds normal claims via the
shared builder plus the audit claim, and logs the mint.

**Files affected**:
- `rails/app/controllers/api/v1/oidc_mint_controller.rb` — NEW.
- `rails/config/routes.rb` — inside `namespace :jwt`, add an **explicit** mapping so the separate
  controller (Q4) is reached at the documented URL: `post 'oidc_mint', to: '/api/v1/oidc_mint#create'`.
  The absolute (leading-slash) `to:` target keeps the controller `API::V1::OidcMintController` (a sibling
  of `JwtController` in the `api/v1` module), rather than `API::V1::Jwt::OidcMintController` that a
  namespace-relative `to: 'oidc_mint#create'` would imply; a bare `post :oidc_mint` would instead map to
  `JwtController#oidc_mint`.
- specs (see Testing).

**Estimated diff size**: ~140 lines.

```
POST /api/v1/jwt/oidc_mint   →  API::V1::OidcMintController#create
Auth:   Authorization: Bearer <google OIDC service token>   (existing OIDC bearer strategy)
Params: firebase_token   (required, the forwarded student Firebase JWT, sent as a body param)
        token_type       (required, "learner" | "teacher")
        class_id         (optional, target class for a cross-class teacher mint)
        description      (optional, short audit label, e.g. "ai4vs-flvs/random-assignment";
                          log-only, never an authorization input — see D7)
```

Logic:
1. Require `request.env['portal.auth_strategy'] == 'oidc_bearer_token'` (as `oidc_send` does) AND the
   authenticated OIDC client has `can_mint_scoped_tokens` true. Do **not** consult `can_access_user`; do
   **not** require the mapped user to be an admin (D1). Fail closed otherwise.
2. `result = ForwardedFirebaseToken.verify(params[:firebase_token])` → `{ user, origin_offering,
   origin_clazz }`. Any `ForwardedFirebaseToken::Invalid` fails closed (mint nothing). Surface the
   `:expired` reason distinctly (D4).
3. Resolve subject and scope:
   - `token_type == "learner"`: subject = the student (`result.user`), scoped to `result.origin_offering`.
     Use the shared builder's **portal** learner shape, resolving the learner via
     `result.origin_offering.find_or_create_learner(result.user.portal_student)`. Not the `firebase`
     action's sub_claims shape (that carries `class_hash`); this is a portal token.
   - `token_type == "teacher"` and no `class_id`: subject =
     `least_privileged_teacher(result.origin_clazz.teachers)` (Q2); scope = origin class. Fail closed if
     the helper returns nil (no teacher).
   - `token_type == "teacher"` with `class_id`: `target = Portal::Clazz.find_by(id: class_id)`; **fail
     closed immediately if `target` is nil** (an unknown id → `find_by` nil → `target.teachers` would
     raise a 500). Then require `(result.origin_clazz.teachers.to_a & target.teachers.to_a).any?`;
     subject = `least_privileged_teacher` of that intersection (Q2); scope = target class. Fail closed if
     the intersection is empty. (Same resolve → nil-check → use ordering as New work B.)
   - Any other `token_type` → refuse (D2).
4. Sanitize `description` before any use (D7): `params[:description].to_s[0, 100].gsub(/[\r\n]/, ' ')`,
   blank → `(none)`. Never branch on its value.
5. Build claims via the shared `PortalTokenClaims` builder, using the **normal** claim building including
   `add_admin_claims` and the **standard TTL** (D8 withdrawn, D4 short-TTL dropped; do not suppress,
   rewrite, or shorten). Add only the **audit claim** (`minted_via_oidc_client_id`, `origin_offering_id`,
   `origin_class_hash`, `minted_for` = the sanitized `description`) (D5).
6. Log the mint (client id, token_type, subject id, origin offering/class, sanitized description).
   Fail-closed everywhere returns no token.
7. Downstream marker visibility happens in the `Current`/propagation step, not here (the pipeline's
   endpoints never reach `check_for_auth_token`).

Teacher selection helper (Q2):

```ruby
def least_privileged_teacher(teachers)
  # teachers are Portal::Teacher records; the token subject needs a real User, so drop nil-user
  # teachers (the same nil-user case guarded in send_class_teachers).
  candidates = teachers.select { |t| t.user }.sort_by(&:id)
  return nil if candidates.empty?
  candidates.reject { |t| elevated_user?(t.user) }.first || candidates.first
end

def elevated_user?(user)
  # Any role that widens authority beyond a plain teacher (see D2 / Q2). Kept intentionally broad:
  # global admin/manager/researcher plus project-level admin/researcher.
  user.has_role?('admin', 'manager', 'researcher') ||
    user.is_project_admin? || user.is_project_researcher?
end
```

The candidate set is one class's co-teachers (or the two-class intersection), so it is tiny; the
per-teacher role lookups are not a performance concern.

---

### Guard the existing jwt actions — D1 containment + D9 no re-minting (New work A2)

**Summary**: Deny the two most dangerous token-issuing actions to (a) OIDC service tokens (D1) and (b)
already-minted marked tokens (D9). **Ships together with the `Current`/propagation step.**

**Files affected**:
- `rails/app/controllers/api/v1/jwt_controller.rb` — a `before_action`.

**Estimated diff size**: ~15 lines.

```ruby
before_action :reject_credential_issuing_callers

def reject_credential_issuing_callers
  current_user   # force the Warden chain so the strategies have run and stamped request.env
  if request.env['portal.auth_strategy'] == 'oidc_bearer_token'          # D1
    return error('This endpoint does not accept OIDC service tokens; use /api/v1/jwt/oidc_mint', 403)
  end
  if Current.minted_via_oidc_client_id.present?                          # D9
    return error('A service-minted token may not be used to mint another token', 403)
  end
end
```

Notes:
- **`current_user` must be called first** (the lazy-Warden trap): `portal.auth_strategy` is only stamped
  once a strategy runs; reading `request.env` without forcing auth can run before any strategy and both
  checks silently pass. Reuse the pattern the old `ForwardedAuthGuard` used.
- **The D9 check reads `Current`, not `request.env`**: this controller decodes the header itself via
  `check_for_auth_token`, so a session can satisfy `current_user` without the bearer strategy stamping
  `request.env`. `Current` is set in both decode paths, so it is visible however the token was honored.
- Verified safe for D1: report-service makes no `/api/v1/jwt` calls; the AP reaches these with a portal
  JWT or session, not an OIDC token.
- Both actions covered deliberately: a minted teacher token at `#firebase` would mint a *Firebase* token
  granting teacher-scoped Firestore access, worse than a portal remint.
- Lives on `JwtController` only. `OidcMintController` is a separate class (Q4) and must not inherit this
  guard; the mint needs no D9 guard of its own (it requires `oidc_bearer_token`, so a portal token cannot
  reach it).

---

### Confine marked tokens — D11 (New work A4)

**Summary**: Two fail-closed rules: marked tokens are valid only within the API namespace, and may never
create an `AccessGrant`. Both depend on the `Current` step. Neither is a substitute for the D10 session
fix (once a marked token becomes a session there is no marker and both go inert) — they are defense in
depth.

**Files affected**:
- `rails/app/controllers/application_controller.rb` — `before_action`, skipped for API controllers.
- `rails/config/routes.rb` — a comment at the `Delayed::Web::Engine` mount noting engines bypass the
  filter (no wrapper — see the mounted-engine resolution below).
- `rails/spec/routing/` (or an existing routes spec) — a **guard spec** tripwire (see below).
- `rails/app/models/access_grant.rb` — `before_create`.

**Estimated diff size**: ~40 lines.

How the two rules divide with D9 propagation (why both mechanisms exist):

| JWT-issuing site | Controller | Covered by |
|---|---|---|
| `home#authoring_site_redirect` | `HomeController` (non-API) | **D11** denies outright |
| `classes#log_links` | `API::V1::ClassesController` (API) | **D9** propagation — D11 does not deny it |
| `jwt_controller#portal` / `#firebase` | API | **D9** explicit denial (New work A2) |

**Rule 1 — API-namespace confinement.** A `before_action` on `ApplicationController`, skipped for API
controllers. `API::APIController < ApplicationController`, so testing ancestry is fail-closed: any new
non-API controller denies marked tokens automatically.

```ruby
# app/controllers/application_controller.rb
before_action :confine_service_minted_tokens

def confine_service_minted_tokens
  return if is_a?(API::APIController)
  current_user   # force the Warden chain — without this the guard is a silent no-op (lazy Warden)
  return if Current.minted_via_oidc_client_id.blank?
  render json: { success: false, message: 'A service-minted token may only be used on the API' },
         status: 403
end
```

This denies the Devise identity surface (registrations, passwords, confirmations, omniauth linking — a
single request could otherwise change the teacher's password and take the account over permanently and
unmarked), the OAuth authorize/token endpoints, and `authoring_site_redirect`. Devise's own controllers
are covered (`Devise.parent_controller` is `ApplicationController`).

**Mounted Rack engines do not run `ApplicationController` filters — resolved: defer with a tripwire.**
`routes.rb:543` mounts the only engine, `Delayed::Web::Engine` at `/delayed_job`, behind a route
constraint that reads `warden.user`:

```ruby
mount Delayed::Web::Engine, at: "/delayed_job", :constraints => lambda { |request|
  warden = request.env['warden']
  warden.user && warden.user.has_role?("admin")
}
```

Verified (code + runtime): this engine is **already fail-closed for bearer tokens** — `Warden::Proxy#user`
(warden 1.2.9) reads `session_serializer.fetch(scope)` and never runs strategies, so a marked bearer token
with no session gets `warden.user == nil` → 404 before any engine code runs. Reaching it requires a
session first, which is **D10's gap**, at which point the marker is already lost. So a `Current`-based
wrapper here would detect nothing, and Rack middleware would have to force `warden.authenticate` itself
(re-triggering the D10 session-store behavior) for zero current threat. Decision (see requirements.md
"D11 mounted-engine coverage"): **neither wrapper nor middleware now.** Instead:

- Add a comment at the mount noting engines bypass `confine_service_minted_tokens` and that any future
  **bearer/portal-token-authed** engine must add marked-token confinement (Rack middleware at that point).
- Add a **guard spec** so a new mount cannot slip past unreviewed:

```ruby
# rails/spec/routing/mounted_engines_spec.rb (or fold into an existing routes spec)
# Tripwire: D11 confinement (ApplicationController before_action) does not run for mounted Rack engines.
# If you add a `mount`, decide how marked (service-minted) tokens are confined for it, then update this list.
it 'has no unreviewed mounted engines' do
  mounts = File.readlines(Rails.root.join('config/routes.rb')).grep(/^\s*mount\s/)
  expect(mounts.size).to eq(1)
  expect(mounts.first).to match(%r{Delayed::Web::Engine.*/delayed_job})
end
```

**Rule 2 — `AccessGrant` refusal at the model** (holds for any caller, not any one route):

```ruby
# app/models/access_grant.rb
before_create :refuse_service_minted_tokens

def refuse_service_minted_tokens
  return if Current.minted_via_oidc_client_id.blank?
  errors.add(:base, 'cannot be created from a service-minted token')
  throw :abort
end
```

---

### Add the teacher-notification email endpoint (New work B)

**Summary**: A portal-token (`jwt_bearer_token`) authed action, NOT OIDC. Sends `subject`/`message` to
all non-blank teacher emails of a `class_id` the acting teacher teaches. Added to `emails_controller` with
`require_oidc_auth!` skipped for this action only.

**Files affected**:
- `rails/app/controllers/api/v1/emails_controller.rb` — new `send_class_teachers` action +
  `skip_before_action :require_oidc_auth!, only: [:send_class_teachers]`.
- `rails/app/policies/portal/clazz_policy.rb` — public `send_class_teachers?` delegating to the private
  `class_teacher?` helper (Pundit needs a public query method).
- `rails/config/routes.rb` — `POST /api/v1/emails/send_class_teachers`.

**Estimated diff size**: ~60 lines.

```
POST /api/v1/emails/send_class_teachers
Auth:   Authorization: Bearer <portal teacher JWT>   (jwt_bearer_token; current_user = the minted teacher)
Params: subject   (required, String)
        message   (required, String)
        class_id  (required — there is no self-send fallback, Q1b)
```

Logic (**order matters** — see step 3):
1. `require_api_user!` (portal user present).
2. `class_id` required: a missing one is a `400` via `params.require(:class_id)` (as `oidc_send` requires
   its params). Never fall back to a recipient.
3. `clazz = Portal::Clazz.find_by(id: class_id)`; **if nil, return `error('The requested class was not
   found')` (400) and stop — before calling `authorize`.** Passing nil to Pundit raises
   `Pundit::NotDefinedError` (not rescued by `application_controller.rb:23`, which rescues only
   `NotAuthorizedError`), so an unknown `class_id` would surface as a **500**. The 400 + message matches
   `classes_controller`'s convention.
4. `authorize clazz, :send_class_teachers?` → `403` if `current_user` is not a teacher of the class.
   `Portal::ClazzPolicy#class_teacher?` is a private helper (Pundit needs a public query method), so add
   a public `send_class_teachers?` that delegates to it; the authorization is the same "teacher of the
   class" check named throughout as `class_teacher?`.
5. Recipients = `clazz.teachers.map { |t| t.user&.email }.reject(&:blank?)`. If empty → `error(..., 422)`,
   send nothing (RIGSE-353 carryover). 422 means exactly: class exists, caller authorized, no usable
   recipient.
6. Validate `subject`/`message` are Strings (else 422). Strip CR/LF from `subject`.
7. `OidcMailer.send_message(recipients, sanitized_subject, message).deliver_now`, wrapped in a rescue
   returning `502` on delivery failure (mirror `oidc_send`). An array `to:` puts every co-teacher in a
   shared `To:` header (acceptable v1).
8. Return `{ success: true, message: 'Email sent' }`; log fact-only (recipients count, class id,
   sanitized subject, that the token was OIDC-minted). No recipient address is read from params.

---

### Tests

**Summary**: Request-level specs covering every fail-closed path and the audit-trail end to end. The D10
gap gets a **pending** test, not a missing one.

**Files affected**: specs under `rails/spec/` for the mint controller, the jwt-controller guard, the D11
rules, the email endpoint, and the claim-builder refactor regression.

**Estimated diff size**: ~400 lines.

- Reuse/adapt the survivor specs for `SignedJwt.decode_firebase_token_by_iss` and `ForwardedFirebaseToken`.
- **Mint request specs**: `can_mint_scoped_tokens` true/false + a client that never set it (proving
  `default: false` denies); invalid/expired/missing `firebase_token`; learner vs teacher; cross-class
  shared-teacher pass/fail; `token_type: user` refused; audit claim present; `description` sanitized
  (CR/LF stripped, length capped), absent `description` still mints, and `description` never changes the
  minted subject/scope. Add the Q2 cases: mixed eligible set → non-elevated subject (lowest id);
  elevated-only set → still mints for the lowest-id elevated teacher.
- **Containment spec (D1)**: an `oidc_bearer_token` request to `jwt_controller#portal` with
  `resource_link_id` + `target_user_id` is denied. Run it with an **admin** mapped user specifically (a
  teacher-mapped user is already denied by `can_access_user`, so it would pass vacuously). Same for
  `#firebase`; assert portal-JWT and session callers still succeed.
- **No-remint spec (D9)**: present a genuinely minted token to `jwt_controller#portal` and `#firebase`;
  both denied; assert **no new token is issued**. One variant **with a session cookie also present** (the
  case that breaks a `request.env`-based guard).
- **Propagation spec (D9, the important one)**: present a minted **admin**-teacher token to
  `classes#log_links`, decode the issued token, assert it **carries `minted_via_oidc_client_id`**. Use
  `log_links` (API namespace, so D11 does not deny it) — the case propagation genuinely has to cover.
- **Duplicate-claim spec**: a normal mint (which sets the marker explicitly) still succeeds with
  propagation active (`create_portal_token`'s duplicate-claim `fail` not tripped).
- **`Current` hygiene spec**: the marker does not leak between requests.
- **D11 namespace specs**: a marked token is denied on `home#authoring_site_redirect`, the Devise identity
  routes, and the OAuth authorize/token endpoints; accepted on the pipeline's API endpoints. Assert a
  **password change** attempt fails specifically (the permanent-takeover case).
- **D11 `AccessGrant` spec**: creation refused while `Current.minted_via_oidc_client_id` is set,
  unaffected otherwise.
- **D10 pending spec (expected to fail until the separate story lands)**: presenting a marked token must
  not establish a Rails session. Mark pending/skipped with a reference to the D10 story — a missing test
  reads as "not a problem", a pending one as "known gap".
- **Guard-ordering spec (the subtle one)**: the guard rejects when the credential arrives **only** in the
  `Authorization` header with no prior authentication (the lazy-Warden regression).
- **Claim-stamping spec (D5)**: a request carrying a minted token has `Current.minted_via_oidc_client_id`
  / `minted_for` set by the `jwt_bearer_token` strategy.
- **Claim-parity spec (replaces the withdrawn D8 test)**: mint a teacher token for a teacher fixture who
  holds `admin` **and** is a project admin; assert its claims match `jwt_controller#portal`'s output for
  that same user, differing only in expiry and the audit claim.
- **Refactor regression**: `JwtController#portal` emits identical claims and TTL before and after the
  shared-builder extraction (existing jwt specs unmodified).
- **Teacher-email request specs**, one per failure mode, each asserting **no email was sent**: minted
  teacher token + owned `class_id` → sends to all class teachers; missing `class_id` → 400; **unresolvable
  `class_id` → 400, explicitly asserting it is not a 500**; `class_id` not taught → 403; learner token →
  403; class with no non-blank teacher email → 422; nil-`user` teacher does not raise; no recipient param
  read; delivery failure → 502.
- **Round-trip**: mint a teacher token, then call enroll / offering-state / teacher-email with it; assert
  normal teacher authorization applies and calls are logged as script-minted.

---

## Build-order / co-ship constraints

- The **`Current`/propagation step** and the **`jwt_controller` guard step** must ship together:
  propagation without the guard denies nothing; the guard without propagation has no marker to check.
- The mint action depends on the survivors, the `Admin::OidcClient` flag, and the shared claims builder.
- D11 rules depend on the `Current` step having set the marker.
- Everything in this plan is **Phase 1** (single portal deploy, additive; spring untouched). Phases 2-5
  (enable minting, report-service migration, spring migration, neutralize the mapped user) are in the
  Rollout section of requirements.md.

## Downstream contract (report-service, sibling story — informational)

Not built here; recorded so the portal side is unambiguous.

- Function calls `POST /api/v1/jwt/oidc_mint` **per scope, cached for the run**, sending its OIDC service
  token + the forwarded `firebaseJwt`, asking for `teacher` (+ `class_id` for enroll-into-assigned-class).
  Each call passes `description` = `"<pipeline>/<step>"`. One or two mints per stage run, not one per step.
- `StepContext` is built once per run and gains `portalTokens?: Map<string, string>` (scope key → minted
  portal JWT). Cache key = the scope (`"teacher"`, `"teacher:<classId>"`). There are three
  `portalOidcFetch` call sites today (`send-email.ts:65`, `lock-activity.ts:30`,
  `random-assignment.ts:396`).
- The mint call keeps using `portalOidcFetch` (OIDC-authed); `portal-api.ts` gains a **sibling** for
  portal-JWT calls (note: `portalOidcFetch` sets `Authorization` after spreading `extraHeaders`, so a
  separate function or an `auth: "oidc" | "portal"` option is required).
- Per-run cache needs no expiry bookkeeping (a direct benefit of D4 dropping the short TTL). Retries
  re-mint by default (fresh `StepContext` per attempt); the caveat is D4's expired-Firebase-input case.
- Email step: mint a teacher token for the origin class, then call `send_class_teachers` with `class_id` =
  the origin class. Stops calling `oidc_send`.
- **Expired-input handling (D4)**: if the mint reports the Firebase token expired, the step **returns**
  `{ success: false, message }` (not throw), so `markComplete(..., "failure")` runs and Cloud Tasks does
  not retry a doomed attempt; the message tells the student to click again. Bound `maxRetryDuration` below
  the token lifetime.
