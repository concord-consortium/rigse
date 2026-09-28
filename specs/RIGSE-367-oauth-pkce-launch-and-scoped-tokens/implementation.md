# Implementation Plan: RIGSE-367: OAuth2 PKCE launch and capability-scoped portal tokens

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-367
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## How this plan was verified

The whole plan was built as throwaway code on this branch during stage 5 (2026-09-28), run, and then removed from the working tree; the build is saved as the branch oob file `stage5-throwaway-build.patch` (rigse, branch `RIGSE-367-oauth-pkce-scoped-tokens`), which applies to `master` at `195ebd38b`. Implementation starts from it, step by step, rather than from this document's excerpts, which show the shape of each step and the code a reviewer most needs to see. What the build established:

- The existing specs of every area it touches (auth controller, access grants, clients, the JWT controller and its RIGSE-352 guard specs, the confinement spec, the API controller, the three bearer strategies, users, research classes, external reports, the OIDC mint, `SignedJwt`, admin clients, request specs) pass, 465 examples, after the spec changes listed in each step; the four RIGSE-352 guard specs that stubbed `current_user` to set the marker now present a real marked token, which is what the new check reads.
- The new specs pass: `scoped_oauth_flow_spec.rb` (12 examples, the whole launch end to end), `token_scope_spec.rb`, `token_capability_check_spec.rb`, `portal_assertions_spec.rb`, the enabled D10 spec, and the additions to the `SignedJwt`, access grant, client, external report, research classes, OIDC mint and auth controller specs.
- Reverting the `store?` override fails both "never becomes a session" examples (the D10 spec and the flow spec), so the specs guard the thing they name.
- The build found a defect the requirements did not: `url_for_class` is called with the protocol both as `request.protocol` (`"https://"`) and bare (`"https"`, in the model's own spec), so `authDomain` is built from both forms (the scoped branch of the launch step).
- Rails 8 draws routes lazily in test, and Devise registers its Warden strategies from `devise_for`, so the first request of a test process authenticates without them; that is the "cold-boot first-request auth quirk" RIGSE-352's confinement spec mentions. Request specs that present a bearer call `Rails.application.reload_routes_unless_loaded` in `before(:all)`. Production eager-loads routes and is unaffected.
- `eslint` and `tsc --noEmit` are clean for the table change.
- The full suite result is recorded under "Full suite" at the end. The build's migration was rolled back in the local development database when the build was removed, so the database matches `master` again.

## Implementation Plan

### The portal signing key and the RS256 tokens

**Summary**: The environment's RS256 key, the signing of the two service assertions and of the scoped access token, and `decode_portal_token` routing by `kid` so rigse accepts its own access token (RFC 9068, `typ: at+jwt`, rigse in `aud`) and nothing else RS256. Nothing issues an access token until the PKCE step, so this step changes no behaviour a caller can reach. Carried over from #1487 where the review kept it (R1 to R6, R9, R12).

**Files affected**:
- `rails/lib/portal_signing_key.rb` (new, from #1487 unchanged): `configured?`, `kid`, `private_key`, `verification_key(kid)` (an `OpenSSL::PKey`, never a PEM string; an unknown `kid` raises), `PORTAL_PREVIOUS_VERIFY_KEYS`.
- `rails/lib/tasks/portal_signing_key.rake` (new, from #1487 unchanged): `generate KID=...` and `public`.
- `rails/lib/signed_jwt.rb`: `AUD_REPORT_SERVER`, `AUD_REPORT_SERVICE_FUNCTIONS`, `ACCESS_TOKEN_TYPE`; `create_assertion`, `create_access_token`, private `sign_rs256`; `decode_portal_token` routes by `kid`. `create_portal_token` is unchanged in this step.
- `rails/spec/spec_helper.rb`: `require "openssl"` and a generated test key, before Rails loads (from #1487).
- `rails/spec/libs/portal_signing_key_spec.rb` (new, from #1487), `rails/spec/libs/signed_jwt_spec.rb` ("RS256 tokens").
- `docker-compose.yml`, `.env-osx-sample`, `.env-gh-codespaces-sample`, `configs/cloudformation/stack_template.yml` (`PortalSigningKey`, `PortalSigningKeyId`, `PortalPreviousVerifyKeys`, each behind an `!If`), `README.md` ("Portal signing key and scoped OAuth clients", its key and rotation paragraphs).

**Estimated diff size**: ~480 lines, about half of them specs and configuration.

```ruby
# rails/lib/signed_jwt.rb (the new and changed methods)
AUD_REPORT_SERVER            = 'report-server'.freeze
AUD_REPORT_SERVICE_FUNCTIONS = 'report-service-functions'.freeze
ASSERTION_AUDIENCES = [AUD_REPORT_SERVER, AUD_REPORT_SERVICE_FUNCTIONS].freeze
ACCESS_TOKEN_TYPE = 'at+jwt'.freeze

def self.create_assertion(user, aud:, claims: {}, expires_in:)
  raise SignedJwt::Error.new("Unknown assertion audience: #{aud}") unless ASSERTION_AUDIENCES.include?(aud)
  now = Time.now.to_i
  payload = { iss: APP_CONFIG[:site_url], aud: aud, iat: now, exp: now + expires_in, uid: user.id }
  payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
  sign_rs256(payload)
end

def self.create_access_token(user, client_id:, capabilities:, context:, audiences:, expires_in:)
  now = Time.now.to_i
  payload = { iss: APP_CONFIG[:site_url], sub: user.id.to_s, uid: user.id, aud: audiences, client_id: client_id,
              scope: capabilities.join(' '), iat: now, exp: now + expires_in, jti: SecureRandom.uuid }
  payload[:context] = context if context
  sign_rs256(payload, typ: ACCESS_TOKEN_TYPE)
end

def self.decode_portal_token(token)
  begin
    header = JWT.decode(token, nil, false)[1]
    decoded =
      if header.key?('kid')
        raise SignedJwt::Error.new('An RS256 portal token must be an access token') unless header['typ'] == ACCESS_TOKEN_TYPE
        JWT.decode(token, nil, true, { algorithm: PortalSigningKey::ALGORITHM, aud: APP_CONFIG[:site_url], verify_aud: true }) do |h|
          PortalSigningKey.verification_key(h['kid'])
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

`decode_portal_token` keeps its one-argument signature, so its two callers are unchanged: #1487's `aud:` keyword existed to let each call site name an audience, and rigse now accepts exactly one kind of RS256 token. The specs cover an `aud` list containing rigse, an `aud` without it, a non-`at+jwt` token and an assertion (both refused), the alg-confusion forgery, an unknown `kid`, another environment's key under the same `kid`, a legacy HS256 token, and one audience per assertion. For R9a, they also check that an assertion's `aud` is always a string (a list audience and an `aud` smuggled in through `claims:` are both refused) and that an access token's `aud` list never names an assertion audience.

---

### Capabilities and the scoped-token check

**Summary**: The capability registry, the shared reader of a token's scope, context and marker, the global check, the Devise strategy's per-token `store?`, and RIGSE-352's guards moved onto the convention (R10, R11, R13 to R27). After this step a scoped token is limited wherever it is presented, and a minted token carries `portal-api`.

**Files affected**:
- `rails/lib/token_capabilities.rb` (new): the registry (name, context type, audience, gate), `parse`, `context_types`, `audience_value` (rigse is `site_url`; report-server is `REPORT_SERVER_URL`, never `report-server`), `missing_settings`, and `Denied`.
- `rails/lib/token_scope.rb` (new): `apply!(claims)` onto `Current` (a marked token with no scope becomes `portal-api`, R20), `scoped?`, `capabilities`, `allows?(capability, object)`, `inherited_claims`.
- `rails/lib/portal_bearer.rb` (new): the request's portal JWT and its verified claims, with the header matching the JWT strategy's (`Bearer/JWT`, or `Bearer` with dots and `portal_token?`).
- `rails/app/models/current.rb`: `token_scope`, `token_context`.
- `rails/app/services/portal_assertions.rb` (new): `report_server(user:, clazz:)` and `report_service_functions(user:)`, #1487's `ResearcherDashboard::Assertions` renamed, since nothing in them is the dashboard's, with `context` (built from `TokenCapabilities::CLASS_CONTEXT`, which is why it lands in this step) in place of `scope_kind`/`scope_id`, and `user_type: 'researcher'` kept. Its spec, `rails/spec/services/portal_assertions_spec.rb`, lands with it.
- `rails/app/controllers/concerns/token_capability_check.rb` (new): `accepts_token_capability`, `accepts_no_token_capabilities`, `enforce_token_capabilities`, `require_token_capability!`, and the 403.
- `rails/app/controllers/application_controller.rb`: includes the concern; `before_action :enforce_token_capabilities` takes `confine_service_minted_tokens`' place in the chain, and that method is deleted.
- `rails/app/controllers/api/api_controller.rb`: `accepts_token_capability TokenCapabilities::PORTAL_API`; `check_for_auth_token` calls `TokenScope.apply!(data)` in place of setting the marker itself.
- `rails/app/controllers/api/v1/jwt_controller.rb`: `accepts_no_token_capabilities`, so every `jwt/*` action refuses a scoped token; the marker check is removed from `reject_credential_issuing_callers`, which keeps D1. The researcher Firebase mint's declaration arrives with its class check, in the researcher gate step.
- `rails/lib/jwt_bearer_token_authenticatable.rb`: `TokenScope.apply!(data)`, `@scoped`, and `store?`.
- `rails/app/models/access_grant.rb`: `refuse_service_minted_tokens` also refuses while `TokenScope.scoped?` (R24).
- `rails/lib/signed_jwt.rb`: `create_portal_token` merges `TokenScope.inherited_claims` (R23).
- `rails/app/controllers/api/v1/oidc_mint_controller.rb`: `:scope => TokenCapabilities::PORTAL_API` (R19).
- Specs: `token_scope_spec.rb` (new, including R13a: `class:researcher-run` does not allow `class:researcher-read`) and `token_capability_check_spec.rb` (new); `jwt_controller_guard_spec.rb` and `service_minted_token_confinement_spec.rb` present real marked tokens and match the new 403 message; `service_minted_session_gap_spec.rb` is enabled (below); `access_grant_spec.rb`'s refusal message; `oidc_mint_controller_spec.rb` asserts the scope; `signed_jwt_spec.rb` asserts inheritance.
- `docs/portal-authentication-unification-design.md`: section 1.1's JWT strategy entry, a note heading section 10's D10 gap, and a new section 11.

**Estimated diff size**: ~480 lines, about half specs.

```ruby
# rails/lib/token_capabilities.rb (the registry)
REGISTRY = [
  Capability.new(name: CLASS_RESEARCHER_READ, context_type: CLASS_CONTEXT, audience: :portal, gate: RESEARCHER_GATE),
  Capability.new(name: CLASS_RESEARCHER_RUN,  context_type: CLASS_CONTEXT, audience: :portal, gate: RESEARCHER_GATE),
  Capability.new(name: PACKAGES_READ,         context_type: nil,           audience: :report_server),
  Capability.new(name: PORTAL_API,            context_type: nil,           audience: :portal)
].index_by(&:name).freeze

# rails/lib/token_scope.rb
def self.apply!(data)
  Current.minted_via_oidc_client_id = data['minted_via_oidc_client_id']
  Current.minted_for                = data['minted_for']
  scope = data['scope']
  scope = TokenCapabilities::PORTAL_API if scope.nil? && data['minted_via_oidc_client_id'].present?
  Current.token_scope   = scope.nil? ? nil : TokenCapabilities.parse(scope)
  Current.token_context = parse_context(data['context'])   # {"type" => String, "id" => Integer} or nil
end

def self.allows?(capability, object = nil)
  return true unless scoped?
  return false unless capabilities.include?(capability)
  context_type = TokenCapabilities.fetch(capability).context_type
  return true if context_type.nil?
  context = Current.token_context
  context.present? && context['type'] == context_type && object.present? &&
    context_type_for(object) == context_type && context['id'] == object.id
end

# rails/app/controllers/concerns/token_capability_check.rb
def enforce_token_capabilities
  claims = PortalBearer.verified_claims(request)   # nil when absent or unverifiable
  TokenScope.apply!(claims) if claims
  return unless TokenScope.scoped?
  return if (declared_token_capabilities & TokenScope.capabilities).any?
  token_capability_denied
end

# rails/lib/jwt_bearer_token_authenticatable.rb
def store?
  !@scoped && super
end
```

**Why the check reads the header rather than Warden.** Forcing `current_user` on every request, as `confine_service_minted_tokens` did outside the API, would authenticate, and so store sessions for, unscoped JWTs on API actions that never touched `current_user`. Reading the bearer through `PortalBearer` avoids that, and keeps the ceiling on a request that also carries a session, which Warden would otherwise prefer (the flow spec's "keeps its ceiling on a request that also carries a session"). `JwtController`'s D9 spec, "holds even with a session present", passes for the same reason.

**The D10 spec.** It authenticates on `GET /api/v1/teacher_classes/1`, which accepts `portal-api` and calls `require_api_user!` before refusing a non-teacher, so Warden asks the strategy whether to store the user; then `GET /auth/user` without a bearer must redirect to login for a marked token and answer 200 for an unscoped one.

---

### The OAuth code-flow fixes

**Summary**: The defects every OAuth client is exposed to (R28 to R31, R35a): single-use codes that expire, codes only on code-flow grants, no NULL-expiry grant trusted, POST-only token endpoints, and `state` on every authorize error redirect.

**Files affected**:
- `rails/app/models/access_grant.rb`: `CodeExpireTime = 5.minutes`; `attr_accessor :issue_code`, set by `get_authorize_redirect_uri` for `response_type=code`; `generate_tokens` gives a code only then; `authenticate` requires a non-blank code created within `CodeExpireTime`; `spend_code!` clears the code with a conditional `update_all`, so two racing redemptions cannot both succeed; `prune!` also deletes unredeemed expired codes; `ValidationResult#error(error, redirect_uri, state = nil)`.
- `rails/app/models/user.rb`: `find_for_token_authentication` requires `access_token_expires_at IS NOT NULL AND > now`, which also covers `token_authenticatable`'s `?access_token=` (it calls the same method).
- `rails/app/controllers/api/api_controller.rb`: a NULL expiry is refused as an expired grant rather than raising `NoMethodError`.
- `rails/app/controllers/auth_controller.rb`: the confidential path refuses a grant whose code cannot be spent (`access_grant.nil? || !access_grant.spend_code!`); the PKCE step adds the verifier check to that condition.
- `rails/config/routes.rb`: `post '/oauth/token'` and `post '/auth/concord_id/access_token'`.
- `rails/config/application.rb`: `config.filter_parameters += [:client_secret, :code_verifier, :token, /\Acode\z/]` (R47b), with `rails/spec/config/filter_parameters_spec.rb` (new) checking that each credential is filtered and that `client_id`, `redirect_uri`, `grant_type`, `code_challenge_method`, `zipcode` and `state` are not.
- Specs: `access_grant_spec.rb` (grants that are redeemed get `issue_code: true`; a grant has no code unless the code flow issued it); `auth_controller_spec.rb` (the auto-generated `GET access_token` becomes a POST; a code redeems once; an expired code is refused and its token never authenticated).

**Estimated diff size**: ~160 lines.

```ruby
def self.authenticate(code, client_id)
  return nil if code.blank?
  AccessGrant.where(code: code, client_id: client_id).where(["created_at > ?", CodeExpireTime.ago]).first
end

def spend_code!
  AccessGrant.where(id: id).where.not(code: nil).update_all(code: nil) == 1
end

def generate_tokens
  self.code = issue_code ? SecureRandom.hex(16) : nil
  self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16)
end
```

The check of production's access logs for GET requests to either token route is done: none in 90 days on learn.concord.org's production portal, against 49 POST token exchanges in the last week alone (requirements, the POST-only decision, has the details). The release runs `AccessGrant.prune!` from a console straight after deploying: the first `oauth_authorize` after the deploy would otherwise delete, inside a user's request, every code-flow grant ever left unredeemed, since nothing has deleted a NULL-expiry row before. The follow-up that turns a missing `redirect_uri` into a refusal (R28a) waits on the release's log lines and on Model My Watershed, which does not send one: its client is deleted if it is unused, or a PR to WikiWatershed/model-my-watershed first adds `redirect_uri` to its token request.

---

### The researcher gate and the Firebase researcher mint

**Summary**: `can_be_researcher_for_clazz?` as the single gate, defined through the batched `researcher_clazz_ids` (from #1487 unchanged), and `jwt/firebase` checking a scoped token's class (R44, R45).

**Files affected**:
- `rails/app/models/user.rb`: `can_be_researcher_for_clazz?`, `researcher_clazz_ids`, and the private `with_teacher_clazzes` shared with `is_researcher_for_clazz?` and `is_project_admin_for_clazz?` (from #1487).
- `rails/app/controllers/api/v1/jwt_controller.rb`: `accepts_token_capability CLASS_RESEARCHER_READ, only: :firebase, if: -> { request.get? && params[:researcher] == "true" }`, and in `firebase`'s researcher branch `require_token_capability!(TokenCapabilities::CLASS_RESEARCHER_READ, clazz)` before `user.can_be_researcher_for_clazz?(clazz)`. The two land together so no commit lets a class-scoped token mint for any class. `Denied` is a `StandardError`, so the controller's `rescue_from StandardError` answers it with the endpoint's existing 400.
- `rails/spec/models/user_spec.rb` (from #1487).

**Estimated diff size**: ~140 lines.

---

### PKCE and scoped clients

**Summary**: `Client#scopes`, the authorization code flow with PKCE for public clients, the scope and context at authorize with the capability's gate, and the scoped access token at `/oauth/token` (R32 to R39, R46's `REPORT_SERVER_URL`).

**Files affected**:
- `rails/db/migrate/20260928120000_add_scopes_and_pkce_to_oauth.rb` (new) and `rails/db/schema.rb`: `clients.scopes`; `access_grants.code_challenge`, `redirect_uri`, `scope`, `context_type`, `context_id`, in one `change_table ... bulk: true`, which emits a single `ALTER TABLE access_grants` (checked by rolling the migration back and forward locally).
- `rails/app/models/client.rb`: `public?`, `scope_list`, `scoped?`, a validation refusing unknown capabilities, and `updated_grant_for` raising for a scoped client (R33a).
- `rails/lib/portal_signing_key.rb`: `usable?`, true only when the configured key parses as an RSA private key (R6).
- `rails/app/controllers/admin/clients_controller.rb`, `rails/app/views/admin/clients/_form.html.haml`, `_show.html.haml`: `scopes`.
- `rails/app/models/access_grant.rb`: `matching_response_type(client, response_type, params)` (a scoped client uses the code flow only; a public one uses the code flow only with a challenge); `validate_oauth_authorize` refuses a challenge method other than S256 and runs `validate_scope_and_context` for a scoped client; `parse_context("class:123")`; `authorize_scope_for(user, scope, context)` (`server_error` when the signing key or a capability's audience is unset, then `access_denied` for a missing or refused object); `get_authorize_redirect_uri` stores the challenge, redirect URI, scope and context on the grant; `verifies_code_verifier?`; `scope_list`; `context`; `generate_tokens` gives a scoped client's grant no opaque token, and `refuse_opaque_grants_for_scoped_clients` refuses any grant for one but a code-flow grant (R33a, R38). `authorize_scope_for` checks `PortalSigningKey.usable?`.
- `rails/app/controllers/auth_controller.rb`: the confidential path also refuses a grant whose challenge the `code_verifier` does not match (`verifies_code_verifier?`, true when the grant has no challenge), and checks the stored `redirect_uri` through `legacy_redirect_uri_matches?` (R28a: a different one refused, a missing one accepted and logged; this lands here rather than in the code-flow step because the column arrives with this step's migration); `access_token` sends a public or scoped client to `pkce_or_scoped_access_token`, which checks `grant_type`, the client (a secret only for a confidential one), the code, the verifier and the redirect URI, then issues the scoped token (deleting the grant as it spends the code) or, for a public client without scopes, the opaque token; errors are RFC 6749 section 5.2 JSON with `Cache-Control: no-store`.
- `rails/config/application.rb`: `resource '/oauth/token', :headers => :any, :methods => [:post]` in the `origins '*'` block.
- `docker-compose.yml`, the env samples, `stack_template.yml` (`ReportServerURL`, named as RIGSE-368 names it so its rebase drops its own), `README.md` (`REPORT_SERVER_URL` and the "Scopes" paragraph).
- Specs: `rails/spec/requests/scoped_oauth_flow_spec.rb` (new, below); `client_spec.rb` (scopes); `access_grant_spec.rb` (a public client's code request without a challenge is `invalid_request`; R24, a scoped `Current` refuses grant creation; R31, `prune!` deletes an unredeemed code past `CodeExpireTime` and keeps a live one); `auth_controller_spec.rb` (R34, a confidential client's challenge is verified; R37, a confidential scoped client without its secret is `invalid_client` 401; R28a, a different `redirect_uri` is refused and a missing one accepted and logged); `client_spec.rb` (R33a, no opaque grant for a scoped client by either path).

**Estimated diff size**: ~520 lines, of which the flow spec is 180; if review wants it smaller, the admin form and the public-unscoped opaque branch split off cleanly.

```ruby
# rails/app/controllers/auth_controller.rb: signed before the code is spent (R38)
def issue_scoped_access_token(client, grant)
  capabilities = grant.scope_list
  audiences = capabilities.map { |c| TokenCapabilities.audience_value(c) }
  return oauth_error("server_error", 500) if audiences.any?(&:nil?)
  ttl = ExternalReport::ReportTokenValidFor.to_i
  token = begin
    SignedJwt.create_access_token(grant.user, client_id: client.app_id, capabilities: capabilities,
      context: grant.context, audiences: [APP_CONFIG[:site_url], *audiences].uniq, expires_in: ttl)
  rescue SignedJwt::Error => e
    Rails.logger.error("OAuth token: could not sign a scoped token for #{client.app_id}: #{e.message}")
    return oauth_error("server_error", 500)
  end
  return oauth_error("invalid_grant", 400) unless AccessGrant.where(id: grant.id).where.not(code: nil).delete_all == 1
  response.headers["Cache-Control"] = "no-store"
  render json: { access_token: token, token_type: "Bearer", expires_in: ttl, scope: capabilities.join(" ") }
end
```

**The flow spec** runs the whole launch through the real middleware stack: a researcher's code carries the class and the scope; another class and a missing class are the same `access_denied` with `state`; a missing context, a missing challenge and `plain` are `invalid_request`; a scope outside the client is `invalid_scope` and the implicit flow is `unauthorized_client`; an unset `REPORT_SERVER_URL` is `server_error` for the full scope and not for `class:researcher-read` alone, and an unset or malformed signing key is `server_error` for any scope with no grant created (R6); the code grant carries no opaque token (R38); a signing failure at the exchange is `server_error` and leaves the code redeemable (R38); the token's claims and header are exactly R7's, with no role flags, and no grant row survives; a second redemption, a wrong verifier, another redirect URI, another `grant_type` and an expired code are refused; GET is not routed and CORS answers; the token mints a Firebase researcher token for its class and not another; it is refused on `jwt/firebase` without `researcher=true` or by POST (R45), `jwt/portal`, `research_classes` and `/auth/user`; it never becomes a session; and it keeps its ceiling on a request that also carries a session.

---

### The Researcher Dashboard as an ExternalReport

**Summary**: The launch link for a scoped report, and the Research Classes rows and table listing class reports that support researchers (R40 to R43).

**Files affected**:
- `rails/app/models/external_report.rb`: `url_for_class` returns `oauth2_url_for_class` when the client is scoped, which appends `authDomain` (built from the protocol in either form it is passed), `classId` and `loginHint` and creates no grant; `url_for_offering` raises `ExternalReport::LaunchNotSupported` for a scoped client (R33a).
- `rails/app/controllers/portal/offerings_controller.rb`: `rescue_from ExternalReport::LaunchNotSupported` answers 404. Between the PKCE step and this one, the same launch fails closed with a 500 from `Client#updated_grant_for`, issuing nothing.
- `rails/app/controllers/api/v1/research_classes_controller.rb`: `classes_mapping` loads the class reports that support researchers once and the permitted class ids once (`researcher_clazz_ids`), and each row carries `external_reports`, with each `url` the existing launch plus `researcher=true`.
- `rails/react-components/src/library/components/researcher-classes-form/table.tsx`: a link per report, labelled `launch_text || name`.
- `README.md`: "Enabling the Researcher Dashboard" (the two admin rows).
- Specs: `external_report_spec.rb` (the scoped launch URL, and that it creates no grant; `url_for_offering` refuses a scoped client's report), `scoped_oauth_flow_spec.rb` (the offering route never launches a scoped report and creates no grant), `research_classes_controller_spec.rb` (the four existing row expectations gain `"external_reports"=>[]`; a new example lists a supporting report and omits a teacher-only one).

**Estimated diff size**: ~120 lines.

```ruby
def oauth2_url_for_class(clazz, user, protocol, host)
  add_query_params(url, {
    authDomain: "#{protocol.to_s.delete_suffix('://')}://#{host}/",
    classId:    clazz.id,
    loginHint:  user.id
  })
end
```

## Open Questions

### RESOLVED: Judgment call: one-argument `decode_portal_token` rather than #1487's required `aud:` keyword
**Context**: #1487 made every call site name the audience it accepted, because rigse then accepted a launch token on some endpoints and not others.
**Options considered**:
- A) Keep the one-argument signature; rigse accepts exactly one kind of RS256 token, its access token, and where it may be used is the capability check's job.
- B) Keep the keyword, with one possible value.

**Decision**: A. Audience no longer varies by call site, so the keyword would carry no information, and the question "may this token be used here" now has one answer in one place (R14) rather than two.

### RESOLVED: Judgment call: the assertions leave the `ResearcherDashboard` namespace
**Context**: #1487 put them in `ResearcherDashboard::Assertions`, and R40 keeps the dashboard's name out of the portal's launch code.
**Options considered**:
- A) `PortalAssertions`, since each is named for the service it is for.
- B) Keep `ResearcherDashboard::Assertions` for RIGSE-368.

**Decision**: A. Nothing in them is the dashboard's, and RIGSE-368 calls them by the service's name either way.

### RESOLVED: Judgment call: a public client without scopes may also use the code flow with PKCE
**Context**: R34 requires PKCE for a public client's code flow and keeps the implicit flow for public clients without scopes; it does not say whether such a client may choose the code flow.
**Options considered**:
- A) Allow it, issuing today's opaque token, so an existing public client can move off the implicit flow without also taking scopes.
- B) Refuse it until the client has scopes.

**Decision**: A. It is the OAuth-recommended migration path the unification design is heading towards, it costs one branch (`issue_opaque_access_token`), and nothing depends on refusing it.

## Self-Review

Roles: the commit reviewer (does each step stand alone), the test runner, the operator who deploys it, and the security engineer, each finding checked against the stage 5 build before it was written. Checked and dropped: the global check running before CSRF protection (it runs after, since `protect_from_forgery` is declared first); the concern's `rescue_from` being shadowed in API controllers (only `JwtController` rescues `StandardError`, where the 400 is intended); the extra decode per bearer request (one RS256 or HS256 verification, the double parse the unification design already accepts).

### Commit reviewer

#### RESOLVED: The researcher Firebase mint's declaration landed two steps before its class check
As first written, the capabilities step declared `class:researcher-read` on `jwt/firebase` and the researcher gate step added `require_token_capability!`, so at the commit between them a class-scoped token would pass the declaration with no check that the class was its own. No such token could be issued at that commit, but each commit should be safe on its own. Fixed: the declaration moves to the researcher gate step, beside the check.

#### RESOLVED: The code-flow step called a method the PKCE step defines
The built `access_token` checks `verifies_code_verifier?` on the confidential path, which the PKCE step adds, so the code-flow step would not load on its own. Fixed: the code-flow step's condition is `access_grant.nil? || !access_grant.spend_code!`, and the PKCE step adds the verifier to it.

### Operator

#### RESOLVED: Five ALTERs on `access_grants`
`add_column` five times is five `ALTER TABLE` statements, each a table rebuild on MySQL 5.7 (the local server here; production moved to Aurora 3 under `docs/mysql-8-upgrade/`), on a table with a row per user and client. Fixed: one `change_table ... bulk: true`, verified to emit a single `ALTER TABLE access_grants` with all five columns.

#### RESOLVED: The first authorize after deploy pays for every unredeemed code ever issued
`prune!` runs inside `get_authorize_redirect_uri`, and the new clause deletes code-flow grants that were never redeemed, which nothing has deleted before. Fixed as a release step in the code-flow step: run `AccessGrant.prune!` from a console straight after deploying.

## As built

Implemented on 2026-09-28, one commit per step, each through a `cc-code-review` pass until it reported nothing actionable. Departures from the plan and review decisions, by step:

### The portal signing key and the RS256 tokens

- **Departure: `create_access_token` guards its own `aud`.** The review found that nothing stopped a caller passing an assertion audience into an access token's `aud` list, which R9a forbids, and that step 1's specs built access tokens by hand instead of through the real encoder. `create_access_token` now raises `SignedJwt::Error` unless the list starts with `site_url` and names neither `report-server` nor `report-service-functions`, and the specs run it through `decode_portal_token` (claims, `typ`, `kid`, a fresh `jti`, `context` present only when given) and check each refused list.
- **Rejected: shorten `PortalSigningKey`'s header comment.** The review called it a duplicate of the README. It is #1487's header, which scytacki reviewed, and it carries the two facts a reader of the code most needs there: the literal `\n` form of the key and that staging and production must never share a keypair.

### Capabilities and the scoped-token check

- **Departure: one Authorization-header parser for all three readers.** The review found, and confirmed with a probe, that the global check matched `Bearer <jwt>` and `Bearer/JWT <jwt>` with exactly one space while `check_for_auth_token` accepted any whitespace, so a scoped or service-minted token sent as `Bearer<TAB><jwt>` or with two spaces passed the global check unseen and was then accepted by `check_for_auth_token` as a full-user credential on every API action, including `jwt/portal`. `PortalBearer.raw_token` is now the only parser: the global check, the Devise JWT strategy's `jwt_token_value` and `check_for_auth_token`'s `extract_bearer_token` all call it. Specs send the three padded forms to an undeclared action and a marked token with a tab to `jwt/portal`, all refused; restoring the single-space pattern fails both.
- **Comments name what they describe, not the ticket:** references to "RIGSE-352" in the new code comments were reworded (the service-mint marker, oidc_mint, Warden's lazy authentication), and the comments in `routes.rb`, `mounted_engines_spec.rb` and the confinement spec that still named the deleted `confine_service_minted_tokens` now name `enforce_token_capabilities`.

### The OAuth code-flow fixes

- **Departure: the implicit flow's redirect is logged as `[FILTERED]`.** The review found that R47b was not met by `filter_parameters` alone: Rails logs `Redirected to <location>` from `response.filtered_location`, which filters a Location's query string but never its fragment, and the implicit flow puts a week-long access token in the fragment (`#access_token=…`). `config.filter_redirect << /[#&]access_token=/` makes Rails log such a redirect as `[FILTERED]`; the spec checks that and that a code-flow redirect still logs with only `code` filtered.
- **Tests added for two behaviours the step had none for:** `check_for_auth_token` refusing a grant whose expiry was never set as an expired grant (R29), and a routing spec that both token routes answer POST and are not routable by GET (R30).

### PKCE and scoped clients

- **Departure: a malformed `code_challenge` is refused at authorize.** The review found that only presence and `code_challenge_method` were checked, so a 300-character challenge reached the 255-character column and raised `ActiveRecord::ValueTooLong`, a 500 for the user. A challenge must now match RFC 7636's 43 to 128 unreserved characters (`AccessGrant::PKCE_VALUE`, which the verifier check shares) or authorize answers `invalid_request` with `state`.
- **Departure: a change of a client's scopes cancels what it no longer covers.** R33a was enforced only when a grant was created, so an existing client an admin gives scopes kept its implicit-flow or report grants, usable as full-user tokens for up to a week, and a code issued before a scope change redeemed under the old scope for up to five minutes. A save that changes a client's scopes now deletes its pending codes, and, when it leaves the client scoped, every grant holding an opaque token; and the token endpoint signs only the capabilities the grant and the client still share, answering `invalid_grant` when none remain.
- **Tests added:** a public client without scopes redeeming a PKCE code for an opaque one-week token (and refused without a challenge), a scoped confidential client redeeming with its secret and no PKCE, and a `code_challenge` sent as an array refused as `invalid_request` rather than raising.

### The Researcher Dashboard as an ExternalReport

- **Departure: project admins may follow a class report's launch link.** The review found that the Research Classes rows list class reports for every class the researcher gate admits, which includes the class's project admins, while `Portal::ClazzPolicy#external_report?` admitted teachers, site admins, class researchers and class students but not project admins, so a project admin who is not a researcher saw a "Researcher Dashboard" link that answered not authorized. `external_report?` now also admits `class_project_admin?`, as `materials?` and `roster?` already do for the same role. This widens every class report's launch, not only the dashboard's, to a role that already has full access to the class's student data (`has_full_access_to_student_data?`); the launch still grants nothing a scoped report's authorize step does not check again.
- **Test added:** a Research Classes row whose class fails the researcher gate lists no reports even when one supports researchers.

### After the six steps: comparing the code with both specs

A requirement-by-requirement comparison found every requirement implemented and no code contradicting one. It found two code gaps and several untested behaviours, which one further commit closes:

- **Departure: a confidential client's PKCE code needs its `redirect_uri`.** R37 requires an identical `redirect_uri` for a code issued with a challenge, but the confidential path's one-release leniency (R28a) also let such a code redeem without one. A client that sends a challenge is new to this flow, so the leniency no longer applies to it.
- **`Portal::LearnersController#report` answers 404 for a scoped client's report**, as the offering routes do. It launches the offering's default report through `url_for_offering`, which raises for a scoped client; only an admin who made a scoped report an offering's default could reach it.
- **Tests added:** a context the scope does not take, or a malformed one (`invalid_request` with `state`); another client's code, on both paths; a narrowed scope signing only what remains and `invalid_grant` when nothing does; the class launch route end to end, redirecting with `authDomain`, `classId` and `loginHint` and creating no grant; `authDomain` from `request.protocol`'s `"https://"`; an RS256 token with no `kid`; the admin form saving normalised scopes; and a Jest test of the table's report links. Not added: specs for the two rake tasks (a key generator and a printer) and assertions on the `server_error` log lines.

## Stage 8 cross-reference

Every requirement maps to a step. Doug's answers, 2026-09-28, each the recommendation:
- **Q1 (R6 had no step).** With no signing key the build issued a code at authorize and then raised at `/oauth/token` after deleting the grant, a 500 in production (a throwaway request spec showed it). Fixed: `authorize_scope_for` answers `server_error` when `PortalSigningKey.configured?` is false, in the PKCE step.
- **Q2 (requirements with no spec).** R24, R31, R34, R37 and R45 gain specs, listed in the PKCE step.
- **Q3 (steps with no requirement).** The unification doc update became R47a, the public-unscoped code flow joined R34, and `Cache-Control: no-store` became R37a.

## External adversarial review

A second model reviewed the spec and the build on 2026-09-28 (`/tmp/rigse-367-adversarial-review.md`); its six findings are recorded, and resolved, at the end of requirements.md. The fixes in this plan: R33a's two layers (the PKCE step's grant refusals, the launch step's offering-route refusal); R28a's `redirect_uri` binding, placed in the PKCE step because it needs the new column; R6's `usable?` and R38's sign-before-spend in the PKCE step; `PortalAssertions` moved to the capabilities step with `user_type` kept. The build was updated with all of them and the affected specs run (141 examples, 0 failures) before the full suite was run again.

## scytacki's answers (2026-09-28)

His answers to the design page's four questions added R9a, R9b and R13a and extended R28a (requirements.md records them). The build gained the R9a and R13a specs, and `signed_jwt_spec.rb` and `token_scope_spec.rb` were run: 26 examples, 0 failures. R9a's multi-audience assertion test belongs to report-service's two verifiers and is recorded as REPORT-141/142 work in the sprint doc.

## Full suite

Every full run is `docker compose run --rm app ./docker/dev/run-spec.sh` with `solr-test` up and nothing else using the test database. The final build, with the stage 8 answers, the adversarial review's fixes, scytacki's R9a and R13a specs and R47b's log filter, ran on 2026-09-28: **3,056 examples, 0 failures, 202 pending**. Before R47b it had run 3,051 with 0 failures. The first build without them had run 3,039 examples with 0 failures. An earlier run without Solr, and alongside other spec runs sharing the test database, showed 284 failures, all in areas the build does not touch; they were the environment. The saved patch is the final build, and the auth-design doc's trailing blank line is gone, so it applies with no whitespace warnings.
