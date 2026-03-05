# OIDC Authentication Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add Google OIDC bearer token authentication so Cloud Functions can call Portal APIs as mapped Portal users.

**Architecture:** A new Devise/Warden strategy (`OidcBearerTokenAuthenticatable`) intercepts `Authorization: Bearer <token>` when the token is a Google OIDC JWT, verifies it against Google's JWKS endpoint via the existing `jwt` gem, and maps the `sub` claim to a Portal user via a new `admin_oidc_clients` table. An admin CRUD UI manages the service account mappings. A fallback rescue in `check_for_auth_token` ensures JwtController handles OIDC tokens gracefully.

**Tech Stack:** Ruby on Rails 8, Devise/Warden, `jwt` gem (already present), Pundit, HAML views, RSpec, MySQL 8

**Design doc:** `docs/specs/2026-02-25-portal-oidc-authentication-design.md`

---

### Task 1: Database Migration — `admin_oidc_clients` Table

**Files:**
- Create: `rails/db/migrate/YYYYMMDDHHMMSS_create_admin_oidc_clients.rb`

**Step 1: Create the migration**

```ruby
class CreateAdminOidcClients < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_oidc_clients do |t|
      t.string :name, null: false
      t.string :sub, null: false
      t.string :email
      t.integer :user_id, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :admin_oidc_clients, :sub, unique: true, name: 'index_admin_oidc_clients_on_sub'
    add_index :admin_oidc_clients, :user_id, name: 'index_admin_oidc_clients_on_user_id'
  end
end
```

Generate with: `docker compose run --rm app bundle exec rails generate migration CreateAdminOidcClients`
Then replace the generated file content with the above.

**Step 2: Run the migration**

Run: `docker compose run --rm app bundle exec rake db:migrate`
Expected: Migration succeeds, table created.

**Step 3: Commit**

```bash
git add rails/db/migrate/*_create_admin_oidc_clients.rb rails/db/schema.rb
git commit -m "feat: add admin_oidc_clients migration"
```

---

### Task 2: Model — `Admin::OidcClient`

**Files:**
- Create: `rails/app/models/admin/oidc_client.rb`
- Create: `rails/spec/models/admin/oidc_client_spec.rb`

**Step 1: Write the failing tests**

```ruby
# rails/spec/models/admin/oidc_client_spec.rb
require 'spec_helper'

describe Admin::OidcClient do
  let(:user) { FactoryBot.create(:user) }

  describe 'validations' do
    it 'is valid with name, sub, and user' do
      client = Admin::OidcClient.new(name: 'Test Client', sub: '12345', user: user)
      expect(client).to be_valid
    end

    it 'requires name' do
      client = Admin::OidcClient.new(sub: '12345', user: user)
      expect(client).not_to be_valid
      expect(client.errors[:name]).to include("can't be blank")
    end

    it 'requires sub' do
      client = Admin::OidcClient.new(name: 'Test', user: user)
      expect(client).not_to be_valid
      expect(client.errors[:sub]).to include("can't be blank")
    end

    it 'requires user' do
      client = Admin::OidcClient.new(name: 'Test', sub: '12345')
      expect(client).not_to be_valid
    end

    it 'requires unique sub' do
      Admin::OidcClient.create!(name: 'First', sub: '12345', user: user)
      duplicate = Admin::OidcClient.new(name: 'Second', sub: '12345', user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:sub]).to include("has already been taken")
    end
  end

  describe 'scopes' do
    it '.active returns only active records' do
      active = Admin::OidcClient.create!(name: 'Active', sub: 'a1', user: user, active: true)
      inactive = Admin::OidcClient.create!(name: 'Inactive', sub: 'a2', user: user, active: false)
      expect(Admin::OidcClient.active).to include(active)
      expect(Admin::OidcClient.active).not_to include(inactive)
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      client = Admin::OidcClient.create!(name: 'Test', sub: '12345', user: user)
      expect(client.user).to eq(user)
    end
  end
end
```

**Step 2: Run tests to verify they fail**

Run: `docker compose run --rm app bundle exec rspec spec/models/admin/oidc_client_spec.rb`
Expected: FAIL — `uninitialized constant Admin::OidcClient`

**Step 3: Write the model**

```ruby
# rails/app/models/admin/oidc_client.rb
class Admin::OidcClient < ApplicationRecord
  self.table_name = 'admin_oidc_clients'

  belongs_to :user

  validates :name, presence: true
  validates :sub, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end
```

**Step 4: Run tests to verify they pass**

Run: `docker compose run --rm app bundle exec rspec spec/models/admin/oidc_client_spec.rb`
Expected: All pass.

**Step 5: Commit**

```bash
git add rails/app/models/admin/oidc_client.rb rails/spec/models/admin/oidc_client_spec.rb
git commit -m "feat: add Admin::OidcClient model with validations and tests"
```

---

### Task 3: JWKS Verification Module — `GoogleOidcVerifier`

**Files:**
- Create: `rails/lib/google_oidc_verifier.rb`
- Create: `rails/spec/libs/google_oidc_verifier_spec.rb`

**Step 1: Write the failing tests**

The tests use locally-generated RSA keys and mock `Net::HTTP` to avoid hitting Google's real JWKS endpoint.

```ruby
# rails/spec/libs/google_oidc_verifier_spec.rb
require 'spec_helper'
require 'google_oidc_verifier'

describe GoogleOidcVerifier do
  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:kid) { 'test-key-id-1' }
  let(:audience) { 'http://localhost:3000' }
  let(:issuer) { 'https://accounts.google.com' }
  let(:now) { Time.now.to_i }

  let(:valid_payload) do
    {
      'iss' => issuer,
      'aud' => audience,
      'sub' => '123456789',
      'email' => 'test@test.iam.gserviceaccount.com',
      'iat' => now,
      'exp' => now + 3600
    }
  end

  let(:jwks_response) do
    jwk = JWT::JWK.new(rsa_key, kid: kid)
    { 'keys' => [jwk.export] }.to_json
  end

  def sign_token(payload, key: rsa_key, key_id: kid)
    JWT.encode(payload, key, 'RS256', { kid: key_id })
  end

  before(:each) do
    # Reset cached keys between tests
    GoogleOidcVerifier.instance_variable_set(:@jwks_keys, nil)
    GoogleOidcVerifier.instance_variable_set(:@jwks_fetched_at, nil)

    # Stub APP_CONFIG
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(audience)

    # Stub Net::HTTP to return our test JWKS
    stub_request(:get, GoogleOidcVerifier::JWKS_URI)
      .to_return(status: 200, body: jwks_response, headers: { 'Content-Type' => 'application/json' })
  end

  describe '.verify' do
    it 'returns decoded payload for a valid token' do
      token = sign_token(valid_payload)
      result = GoogleOidcVerifier.verify(token)
      expect(result['sub']).to eq('123456789')
      expect(result['email']).to eq('test@test.iam.gserviceaccount.com')
    end

    it 'raises error for expired token' do
      payload = valid_payload.merge('exp' => now - 60)
      token = sign_token(payload)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error, /Signature has expired/)
    end

    it 'raises error for wrong audience' do
      payload = valid_payload.merge('aud' => 'https://wrong-site.example.com')
      token = sign_token(payload)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error, /Invalid audience/)
    end

    it 'raises error for wrong issuer' do
      payload = valid_payload.merge('iss' => 'https://evil.example.com')
      token = sign_token(payload)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error, /Invalid issuer/)
    end

    it 'raises error for invalid signature' do
      other_key = OpenSSL::PKey::RSA.generate(2048)
      token = sign_token(valid_payload, key: other_key)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error)
    end

    context 'JWKS key rotation' do
      it 'refreshes keys once when kid is not found, then fails' do
        unknown_kid_token = sign_token(valid_payload, key_id: 'unknown-kid')
        expect { GoogleOidcVerifier.verify(unknown_kid_token) }
          .to raise_error(GoogleOidcVerifier::Error, /Could not find public key/)
        # Should have fetched JWKS twice (initial + one refresh)
        expect(WebMock).to have_requested(:get, GoogleOidcVerifier::JWKS_URI).twice
      end
    end

    context 'JWKS fetch failure' do
      it 'uses stale cached keys when fetch fails' do
        # Prime the cache with a successful fetch
        token1 = sign_token(valid_payload)
        GoogleOidcVerifier.verify(token1)

        # Expire the cache
        GoogleOidcVerifier.instance_variable_set(:@jwks_fetched_at, Time.now - 7200)

        # Make fetch fail
        stub_request(:get, GoogleOidcVerifier::JWKS_URI)
          .to_return(status: 500, body: 'Internal Server Error')

        # Should still work with stale cache
        token2 = sign_token(valid_payload.merge('exp' => Time.now.to_i + 3600))
        result = GoogleOidcVerifier.verify(token2)
        expect(result['sub']).to eq('123456789')
      end

      it 'raises error when fetch fails with no cache' do
        stub_request(:get, GoogleOidcVerifier::JWKS_URI)
          .to_return(status: 500, body: 'Internal Server Error')

        token = sign_token(valid_payload)
        expect { GoogleOidcVerifier.verify(token) }
          .to raise_error(GoogleOidcVerifier::Error, /fetch.*JWKS/i)
      end
    end

    context 'issuer variants' do
      it 'accepts accounts.google.com without https prefix' do
        payload = valid_payload.merge('iss' => 'accounts.google.com')
        token = sign_token(payload)
        result = GoogleOidcVerifier.verify(token)
        expect(result['sub']).to eq('123456789')
      end
    end
  end
end
```

**Step 2: Run tests to verify they fail**

Run: `docker compose run --rm app bundle exec rspec spec/libs/google_oidc_verifier_spec.rb`
Expected: FAIL — `cannot load such file -- google_oidc_verifier`

**Step 3: Write the implementation**

```ruby
# rails/lib/google_oidc_verifier.rb
require 'jwt'
require 'net/http'
require 'json'

module GoogleOidcVerifier
  class Error < StandardError; end

  JWKS_URI = 'https://www.googleapis.com/oauth2/v3/certs'.freeze
  VALID_ISSUERS = ['accounts.google.com', 'https://accounts.google.com'].freeze
  JWKS_CACHE_TTL = 3600 # 1 hour
  CLOCK_SKEW = 30 # seconds

  # Verifies a Google OIDC token and returns the decoded payload.
  # Raises GoogleOidcVerifier::Error on any failure.
  def self.verify(token)
    # Decode header to get kid (without verification)
    header = JWT.decode(token, nil, false)[1]
    kid = header['kid']

    # Find the matching public key
    key = find_key(kid)
    raise Error, "Could not find public key for kid=#{kid}" unless key

    # Verify the token
    expected_audience = APP_CONFIG[:site_url]
    decoded = JWT.decode(
      token,
      key,
      true,
      {
        algorithm: 'RS256',
        verify_iss: true,
        iss: VALID_ISSUERS,
        verify_aud: true,
        aud: expected_audience,
        exp_leeway: CLOCK_SKEW
      }
    )
    payload = decoded[0]

    # Additional issuer check (JWT gem checks iss is IN the array)
    unless VALID_ISSUERS.include?(payload['iss'])
      raise Error, "Invalid issuer: #{payload['iss']}"
    end

    payload
  rescue JWT::ExpiredSignature => e
    raise Error, e.message
  rescue JWT::InvalidIssuerError => e
    raise Error, e.message
  rescue JWT::InvalidAudError => e
    raise Error, "Invalid audience: #{e.message}"
  rescue JWT::DecodeError => e
    raise Error, e.message
  end

  private

  def self.find_key(kid)
    keys = cached_keys
    key = key_for_kid(keys, kid)
    return key if key

    # Key not found — try refreshing once (handles key rotation)
    keys = fetch_keys!
    key_for_kid(keys, kid)
  end

  def self.key_for_kid(keys, kid)
    keys&.find { |k| k[:kid] == kid }&.then { |jwk_data| JWT::JWK.new(jwk_data).public_key }
  end

  def self.cached_keys
    if @jwks_keys && @jwks_fetched_at && (Time.now - @jwks_fetched_at) < JWKS_CACHE_TTL
      return @jwks_keys
    end

    fetch_keys!
  end

  def self.fetch_keys!
    uri = URI(JWKS_URI)
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      if @jwks_keys
        # Use stale cache rather than rejecting all requests
        return @jwks_keys
      end
      raise Error, "Failed to fetch JWKS: HTTP #{response.code}"
    end

    jwks_data = JSON.parse(response.body)
    @jwks_keys = jwks_data['keys']
    @jwks_fetched_at = Time.now
    @jwks_keys
  rescue StandardError => e
    if @jwks_keys
      return @jwks_keys
    end
    raise Error, "Failed to fetch JWKS: #{e.message}"
  end
end
```

**Step 4: Run tests to verify they pass**

Run: `docker compose run --rm app bundle exec rspec spec/libs/google_oidc_verifier_spec.rb`
Expected: All pass.

Note: Tests use `webmock` for HTTP stubbing. If `webmock` is not in the Gemfile, check if it's already available (it often is in Rails test environments). If not, the tests can use manual `Net::HTTP` stubbing instead:
```ruby
allow(Net::HTTP).to receive(:get_response).and_return(
  double('response', is_a?: true, body: jwks_response, code: '200')
)
```

**Step 5: Commit**

```bash
git add rails/lib/google_oidc_verifier.rb rails/spec/libs/google_oidc_verifier_spec.rb
git commit -m "feat: add GoogleOidcVerifier JWKS verification module with tests"
```

---

### Task 4: Devise Strategy — `OidcBearerTokenAuthenticatable`

**Files:**
- Create: `rails/lib/oidc_bearer_token_authenticatable.rb`
- Create: `rails/spec/libs/bearer_token/oidc_bearer_token_authenticatable_spec.rb`

**Step 1: Write the failing tests**

Follow the existing strategy test pattern from `bearer_token_authenticatable_spec.rb` and `jwt_bearer_token_authenticatable_spec.rb`.

```ruby
# rails/spec/libs/bearer_token/oidc_bearer_token_authenticatable_spec.rb
require 'spec_helper'
require 'google_oidc_verifier'

describe OidcBearerTokenAuthenticatable::BearerToken do
  let(:strategy) { OidcBearerTokenAuthenticatable::BearerToken.new(nil) }
  let(:request)  { double('request') }
  let(:mapping)  { Devise.mappings[:user] }
  let(:user)     { FactoryBot.create(:user) }
  let(:params)   { {} }

  before(:each) do
    allow(strategy).to receive(:mapping).and_return(mapping)
    allow(strategy).to receive(:request).and_return(request)
    allow(request).to receive(:params).and_return(params)
    allow(request).to receive(:env).and_return({})
    allow(request).to receive(:request_method).and_return('POST')
    allow(request).to receive(:path).and_return('/api/v1/test')
  end

  describe '#valid?' do
    it 'returns false when no Authorization header' do
      allow(request).to receive(:headers).and_return({})
      expect(strategy.valid?).to be false
    end

    it 'returns false for Bearer with opaque token (no dots)' do
      allow(request).to receive(:headers).and_return({'Authorization' => 'Bearer abc123hex'})
      expect(strategy.valid?).to be false
    end

    it 'returns false for Bearer/JWT scheme' do
      allow(request).to receive(:headers).and_return({'Authorization' => 'Bearer/JWT some.jwt.token'})
      expect(strategy.valid?).to be false
    end

    it 'returns true for Bearer with JWT-shaped token (has dots)' do
      allow(request).to receive(:headers).and_return({'Authorization' => 'Bearer header.payload.signature'})
      expect(strategy.valid?).to be true
    end
  end

  describe '#authenticate!' do
    let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:oidc_sub) { 'google-sa-sub-12345' }
    let(:oidc_email) { 'test-sa@project.iam.gserviceaccount.com' }
    let(:decoded_payload) do
      {
        'iss' => 'https://accounts.google.com',
        'sub' => oidc_sub,
        'email' => oidc_email,
        'aud' => 'http://localhost:3000',
        'exp' => Time.now.to_i + 3600,
        'iat' => Time.now.to_i
      }
    end
    let(:token) { JWT.encode(decoded_payload, rsa_key, 'RS256', { kid: 'test-kid' }) }

    before(:each) do
      allow(request).to receive(:headers).and_return({'Authorization' => "Bearer #{token}"})
    end

    context 'with valid OIDC token and matching active OidcClient' do
      let!(:oidc_client) do
        Admin::OidcClient.create!(name: 'Test SA', sub: oidc_sub, email: oidc_email, user: user, active: true)
      end

      before do
        allow(GoogleOidcVerifier).to receive(:verify).with(token).and_return(decoded_payload)
      end

      it 'authenticates and returns success' do
        expect(strategy.authenticate!).to eql :success
      end

      it 'sets portal.auth_strategy env' do
        strategy.authenticate!
        expect(request.env['portal.auth_strategy']).to eq('oidc_bearer_token')
      end

      it 'sets portal.auth_client env' do
        strategy.authenticate!
        expect(request.env['portal.auth_client']).to eq('Test SA')
      end
    end

    context 'with valid OIDC token but no matching OidcClient' do
      before do
        allow(GoogleOidcVerifier).to receive(:verify).with(token).and_return(decoded_payload)
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end

      it 'logs a warning with sub and email' do
        expect(Rails.logger).to receive(:warn).with(/OidcBearer:.*sub=#{oidc_sub}.*email=#{oidc_email}/)
        strategy.authenticate!
      end
    end

    context 'with valid OIDC token but inactive OidcClient' do
      let!(:oidc_client) do
        Admin::OidcClient.create!(name: 'Disabled SA', sub: oidc_sub, email: oidc_email, user: user, active: false)
      end

      before do
        allow(GoogleOidcVerifier).to receive(:verify).with(token).and_return(decoded_payload)
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end

      it 'logs a warning about inactive client' do
        expect(Rails.logger).to receive(:warn).with(/OidcBearer:.*inactive.*Disabled SA/)
        strategy.authenticate!
      end
    end

    context 'when GoogleOidcVerifier raises an error' do
      before do
        allow(GoogleOidcVerifier).to receive(:verify).and_raise(GoogleOidcVerifier::Error, 'Signature has expired')
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end

      it 'logs the verification failure' do
        expect(Rails.logger).to receive(:warn).with(/OidcBearer:.*Signature has expired/)
        strategy.authenticate!
      end
    end

    context 'when token issuer is not Google (non-OIDC JWT)' do
      before do
        allow(GoogleOidcVerifier).to receive(:verify).and_raise(GoogleOidcVerifier::Error, 'Invalid issuer')
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end
    end
  end
end
```

**Step 2: Run tests to verify they fail**

Run: `docker compose run --rm app bundle exec rspec spec/libs/bearer_token/oidc_bearer_token_authenticatable_spec.rb`
Expected: FAIL — `uninitialized constant OidcBearerTokenAuthenticatable`

**Step 3: Write the implementation**

```ruby
# rails/lib/oidc_bearer_token_authenticatable.rb
require 'google_oidc_verifier'

module OidcBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      oidc_token_value.present?
    end

    def authenticate!
      token = oidc_token_value
      payload = GoogleOidcVerifier.verify(token)

      oidc_client = Admin::OidcClient.active.find_by(sub: payload['sub'])
      unless oidc_client
        if Admin::OidcClient.find_by(sub: payload['sub'])
          Rails.logger.warn("OidcBearer: inactive client=#{Admin::OidcClient.find_by(sub: payload['sub']).name}")
        else
          Rails.logger.warn("OidcBearer: no client found sub=#{payload['sub']} email=#{payload['email']}")
        end
        return fail(:invalid_token)
      end

      request.env['portal.auth_strategy'] = 'oidc_bearer_token'
      request.env['portal.auth_client'] = oidc_client.name
      success!(oidc_client.user)
    rescue GoogleOidcVerifier::Error => e
      Rails.logger.warn("OidcBearer: verification failed - #{e.message}")
      fail(:invalid_token)
    end

    private

    def oidc_token_value
      header = request.headers['Authorization'] || ''
      # Only match standard Bearer scheme (not Bearer/JWT)
      if header =~ /^Bearer ([^\s]+)$/i && $1.include?('.')
        # Must NOT match Bearer/JWT — those go to jwt_bearer_token_authenticatable
        return nil if header =~ /^Bearer\/JWT/i
        $1
      end
    end

  end
end

Warden::Strategies.add(:oidc_bearer_token_authenticatable, OidcBearerTokenAuthenticatable::BearerToken)
Devise.add_module :oidc_bearer_token_authenticatable, :strategy => true
```

**Step 4: Register the strategy in User model**

In `rails/app/models/user.rb`, add `:oidc_bearer_token_authenticatable` to the devise declaration:

```ruby
devise :database_authenticatable, :registerable, :token_authenticatable,
       :confirmable, :bearer_token_authenticatable, :jwt_bearer_token_authenticatable,
       :oidc_bearer_token_authenticatable,
       :recoverable, :timeoutable, :trackable, :validatable, :encryptable,
       :encryptor => :restful_authentication_sha1
```

**Step 5: Run tests to verify they pass**

Run: `docker compose run --rm app bundle exec rspec spec/libs/bearer_token/oidc_bearer_token_authenticatable_spec.rb`
Expected: All pass.

**Step 6: Run existing auth tests to confirm no regressions**

Run: `docker compose run --rm app bundle exec rspec spec/libs/bearer_token/`
Expected: All existing tests still pass.

**Step 7: Commit**

```bash
git add rails/lib/oidc_bearer_token_authenticatable.rb rails/spec/libs/bearer_token/oidc_bearer_token_authenticatable_spec.rb rails/app/models/user.rb
git commit -m "feat: add OidcBearerTokenAuthenticatable Devise strategy with tests"
```

---

### Task 5: OIDC Fallback in `check_for_auth_token`

**Files:**
- Modify: `rails/app/controllers/api/api_controller.rb:26-45`
- Modify: `rails/spec/controllers/api/api_controller_spec.rb` (add test)

**Step 1: Write the failing test**

Add a test to the existing api_controller_spec (or create one if needed) that verifies OIDC tokens fall through gracefully.

```ruby
# Add to existing spec or create new context:
context 'when Bearer token is a non-Portal JWT and current_user is set' do
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  it 'falls through to current_user for unrecognized JWTs' do
    request.headers['Authorization'] = 'Bearer header.payload.signature'
    allow(SignedJwt).to receive(:decode_portal_token).and_raise(SignedJwt::Error, 'Signature verification failed')

    user_result, role = controller.send(:check_for_auth_token, {})
    expect(user_result).to eq(user)
    expect(role).to be_nil
  end

  it 'preserves the existing auth strategy tag set by Devise' do
    request.headers['Authorization'] = 'Bearer header.payload.signature'
    request.env['portal.auth_strategy'] = 'oidc_bearer_token'
    allow(SignedJwt).to receive(:decode_portal_token).and_raise(SignedJwt::Error, 'Signature verification failed')

    controller.send(:check_for_auth_token, {})
    expect(request.env['portal.auth_strategy']).to eq('oidc_bearer_token')
  end
end

context 'when Bearer token is a non-Portal JWT and current_user is nil' do
  before do
    allow(controller).to receive(:current_user).and_return(nil)
  end

  it 'raises an error' do
    request.headers['Authorization'] = 'Bearer header.payload.signature'
    allow(SignedJwt).to receive(:decode_portal_token).and_raise(SignedJwt::Error, 'Signature verification failed')

    expect { controller.send(:check_for_auth_token, {}) }
      .to raise_error(StandardError, 'You must be logged in to use this endpoint')
  end
end
```

**Step 2: Run test to verify it fails**

Run: `docker compose run --rm app bundle exec rspec spec/controllers/api/api_controller_spec.rb`
Expected: FAIL — the current code raises `SignedJwt::Error` instead of falling through.

**Step 3: Modify `check_for_auth_token` to add OIDC fallback**

In `rails/app/controllers/api/api_controller.rb`, wrap the JWT decode in a rescue:

Change lines 28-45 from:
```ruby
if header && (header =~ /^Bearer\/JWT (.*)$/i || (header =~ /^Bearer (.+)$/i && SignedJwt.probably_jwt?($1)))
  portal_token = $1
  decoded_token = SignedJwt::decode_portal_token(portal_token)
  data = decoded_token[:data]
  # ... rest of JWT handling
```

To:
```ruby
if header && (header =~ /^Bearer\/JWT (.*)$/i || (header =~ /^Bearer (.+)$/i && SignedJwt.probably_jwt?($1)))
  portal_token = $1
  begin
    decoded_token = SignedJwt::decode_portal_token(portal_token)
  rescue SignedJwt::Error
    # Not a Portal JWT (e.g., OIDC token already authenticated by Devise).
    # Fall through to current_user without overwriting the auth strategy
    # tag — it was already set by the Devise strategy that authenticated
    # the request (e.g., 'oidc_bearer_token').
    if current_user
      return [current_user, nil]
    else
      raise StandardError, 'You must be logged in to use this endpoint'
    end
  end
  data = decoded_token[:data]
  # ... rest unchanged
```

**Step 4: Run test to verify it passes**

Run: `docker compose run --rm app bundle exec rspec spec/controllers/api/api_controller_spec.rb`
Expected: All pass (new and existing).

**Step 5: Commit**

```bash
git add rails/app/controllers/api/api_controller.rb rails/spec/controllers/api/api_controller_spec.rb
git commit -m "feat: add OIDC fallback rescue in check_for_auth_token"
```

---

### Task 6: Admin Policy — `Admin::OidcClientPolicy`

**Files:**
- Create: `rails/app/policies/admin/oidc_client_policy.rb`

**Step 1: Write the policy**

Follow the `ClientPolicy` pattern — admin-only access for all actions.

```ruby
# rails/app/policies/admin/oidc_client_policy.rb
class Admin::OidcClientPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        all
      else
        none
      end
    end
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end
end
```

**Step 2: Commit**

```bash
git add rails/app/policies/admin/oidc_client_policy.rb
git commit -m "feat: add Admin::OidcClientPolicy (admin-only)"
```

---

### Task 7: Admin Controller — `Admin::OidcClientsController`

**Files:**
- Create: `rails/app/controllers/admin/oidc_clients_controller.rb`

**Step 1: Write the controller**

Follow the `Admin::ClientsController` pattern exactly.

```ruby
# rails/app/controllers/admin/oidc_clients_controller.rb
class Admin::OidcClientsController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'OIDC client'})
  end

  public

  # GET /admin/oidc_clients
  def index
    authorize Admin::OidcClient
    @oidc_clients = Admin::OidcClient.all.paginate(per_page: 20, page: params[:page])
  end

  # GET /admin/oidc_clients/1
  def show
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
  end

  # GET /admin/oidc_clients/new
  def new
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.new
  end

  # GET /admin/oidc_clients/1/edit
  def edit
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
  end

  # POST /admin/oidc_clients
  def create
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.new(oidc_client_params)

    if @oidc_client.save
      flash['notice'] = 'OIDC client was successfully created.'
      redirect_to action: :index
    else
      render action: 'new'
    end
  end

  # PUT /admin/oidc_clients/1
  def update
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
    if @oidc_client.update(oidc_client_params)
      flash['notice'] = 'OIDC client was successfully updated.'
      redirect_to action: :index
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/oidc_clients/1
  def destroy
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
    @oidc_client.destroy
    flash['notice'] = 'OIDC client was successfully deleted.'
    redirect_to action: :index
  end

  private

  def oidc_client_params
    params.require(:admin_oidc_client).permit(:name, :sub, :email, :user_id, :active)
  end
end
```

**Step 2: Add route**

In `rails/config/routes.rb`, add `resources :oidc_clients` inside the `namespace :admin` block (line ~233, after `resources :clients`):

```ruby
namespace :admin do
  resources :settings
  resources :tags
  # ... existing resources ...
  resources :clients
  resources :oidc_clients
  # ... rest ...
end
```

**Step 3: Commit**

```bash
git add rails/app/controllers/admin/oidc_clients_controller.rb rails/config/routes.rb
git commit -m "feat: add Admin::OidcClientsController and routes"
```

---

### Task 8: Admin Views

**Files:**
- Create: `rails/app/views/admin/oidc_clients/index.html.haml`
- Create: `rails/app/views/admin/oidc_clients/show.html.haml`
- Create: `rails/app/views/admin/oidc_clients/_show.html.haml`
- Create: `rails/app/views/admin/oidc_clients/new.html.haml`
- Create: `rails/app/views/admin/oidc_clients/edit.html.haml`
- Create: `rails/app/views/admin/oidc_clients/_form.html.haml`

**Step 1: Create index view**

```haml
-# rails/app/views/admin/oidc_clients/index.html.haml
= render partial: 'shared/collection_menu', locals: { collection: @oidc_clients, collection_class: Admin::OidcClient }
= render partial: 'show', collection: @oidc_clients, as: :oidc_client
```

**Step 2: Create show view**

```haml
-# rails/app/views/admin/oidc_clients/show.html.haml
= render partial: 'show', locals: { oidc_client: @oidc_client }
```

**Step 3: Create _show partial**

```haml
-# rails/app/views/admin/oidc_clients/_show.html.haml
%div{id: dom_id_for(oidc_client), class: 'container_element'}
  .action_menu
    .action_menu_header_left
      %h3= oidc_client.name
    .action_menu_header_right
      %ul.menu
        %li
          %a{href: edit_admin_oidc_client_path(oidc_client)} edit
        %li
          %a{href: url_for(action: :destroy, id: oidc_client.id), data: {method: 'delete', confirm: "Delete this OIDC client?"}} delete
  %div{id: dom_id_for(oidc_client, :item), class: 'item'}
    %div{id: dom_id_for(oidc_client, :details), class: 'content'}
      %p
        %ul.menu_v
          %li
            Name:
            = oidc_client.name
          %li
            Sub:
            = oidc_client.sub
          %li
            Email:
            = oidc_client.email
          %li
            User ID:
            = oidc_client.user_id
          %li
            Active:
            = oidc_client.active ? 'Yes' : 'No'
```

**Step 4: Create new view**

```haml
-# rails/app/views/admin/oidc_clients/new.html.haml
= form_for(@oidc_client, url: url_for(controller: 'oidc_clients', action: 'create')) do |f|
  = render partial: 'form', locals: { oidc_client: @oidc_client, f: f }
```

**Step 5: Create edit view**

```haml
-# rails/app/views/admin/oidc_clients/edit.html.haml
= form_for(@oidc_client, url: url_for(controller: 'oidc_clients', action: 'update')) do |f|
  = render partial: 'admin/oidc_clients/form', locals: { oidc_client: @oidc_client, f: f }
```

**Step 6: Create _form partial**

```haml
-# rails/app/views/admin/oidc_clients/_form.html.haml
.item
  .content
    - if oidc_client.errors.any?
      %ul.menu_v.error-explanation
        %li OIDC client can't be saved, there are errors in form:
        - oidc_client.errors.each do |error|
          %li= error.message
    %p
      %ul.menu_v
        %li
          Name:
          = f.text_field :name
        %li
          Sub (Google service account unique ID):
          = f.text_field :sub
        %li
          Email (for display only):
          = f.text_field :email
        %li
          User ID (Portal user this service account acts as):
          = f.number_field :user_id
        %li
          Active:
          = f.check_box :active
      = submit_tag
```

**Step 7: Commit**

```bash
git add rails/app/views/admin/oidc_clients/
git commit -m "feat: add admin OIDC client HAML views"
```

---

### Task 9: Integration Test

**Files:**
- Create: `rails/spec/requests/api/v1/oidc_auth_spec.rb`

**Step 1: Write the integration test**

This test verifies the full stack: OIDC token → Devise strategy → `current_user` → Pundit → endpoint success/failure.

```ruby
# rails/spec/requests/api/v1/oidc_auth_spec.rb
require 'spec_helper'

describe 'OIDC Authentication Integration' do
  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:kid) { 'integration-test-kid' }
  let(:admin_user) { FactoryBot.create(:user) }
  let(:oidc_sub) { 'integration-test-sub-123' }

  let(:oidc_payload) do
    {
      'iss' => 'https://accounts.google.com',
      'sub' => oidc_sub,
      'email' => 'test@project.iam.gserviceaccount.com',
      'aud' => APP_CONFIG[:site_url],
      'exp' => Time.now.to_i + 3600,
      'iat' => Time.now.to_i
    }
  end

  let(:oidc_token) { JWT.encode(oidc_payload, rsa_key, 'RS256', { kid: kid }) }

  before do
    # Stub GoogleOidcVerifier at the module level to avoid real HTTP calls
    allow(GoogleOidcVerifier).to receive(:verify).with(oidc_token).and_return(oidc_payload)
  end

  context 'with a registered active OIDC client' do
    before do
      Admin::OidcClient.create!(
        name: 'Integration Test SA',
        sub: oidc_sub,
        email: 'test@project.iam.gserviceaccount.com',
        user: admin_user,
        active: true
      )
    end

    it 'authenticates and sets current_user' do
      # Use a simple GET endpoint that returns current user info.
      # The exact endpoint depends on what's available — adjust as needed.
      get '/api/v1/jwt/portal', headers: { 'Authorization' => "Bearer #{oidc_token}" }
      # We mainly care that the request is authenticated (not 401/403)
      # The specific response depends on the endpoint behavior
      expect(response.status).not_to eq(401)
    end
  end

  context 'without a registered OIDC client' do
    it 'rejects the request' do
      get '/api/v1/jwt/portal', headers: { 'Authorization' => "Bearer #{oidc_token}" }
      # Without a matching OidcClient, Devise strategy fails.
      # The endpoint returns 403 (Pundit) or 401 depending on the endpoint.
      expect([401, 403]).to include(response.status)
    end
  end

  context 'with an invalid OIDC token' do
    before do
      allow(GoogleOidcVerifier).to receive(:verify).and_raise(GoogleOidcVerifier::Error, 'Signature has expired')
    end

    it 'rejects the request' do
      get '/api/v1/jwt/portal', headers: { 'Authorization' => "Bearer #{oidc_token}" }
      expect([401, 403]).to include(response.status)
    end
  end
end
```

Note: The exact endpoint used in the integration test may need adjustment based on what's available and doesn't require additional parameters. The `add_to_class` endpoint from the design doc requires specific setup (student, class, Pundit permissions). A simpler approach is to test against any endpoint that requires authentication. Adjust the endpoint and assertions based on what works in the test environment.

**Step 2: Run integration test**

Run: `docker compose run --rm app bundle exec rspec spec/requests/api/v1/oidc_auth_spec.rb`
Expected: All pass (this is an integration test verifying the full stack already implemented in Tasks 1-5).

**Step 3: Commit**

```bash
git add rails/spec/requests/api/v1/oidc_auth_spec.rb
git commit -m "feat: add OIDC authentication integration test"
```

---

### Task 10: Run Full Test Suite and Final Verification

**Step 1: Run all auth-related tests**

Run: `docker compose run --rm app bundle exec rspec spec/libs/bearer_token/ spec/models/admin/oidc_client_spec.rb spec/libs/google_oidc_verifier_spec.rb spec/requests/api/v1/oidc_auth_spec.rb spec/controllers/api/api_controller_spec.rb`
Expected: All pass.

**Step 2: Run the broader test suite to check for regressions**

Run: `docker compose run --rm app bundle exec rspec spec/controllers/ spec/libs/ spec/models/`
Expected: No new failures.

**Step 3: Commit the design doc updates**

```bash
git add docs/specs/2026-02-25-portal-oidc-authentication-design.md
git commit -m "docs: update OIDC design doc with resolved overlap and logging integration"
```
