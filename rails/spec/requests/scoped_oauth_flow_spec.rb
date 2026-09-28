require 'spec_helper'

# The whole launch of a scoped ExternalReport: the link, the authorization code flow with
# PKCE, the token, and what the token may and may not do.
RSpec.describe 'Scoped OAuth clients', type: :request do
  include Devise::Test::IntegrationHelpers
  include ActiveSupport::Testing::TimeHelpers
  # Rails 8 draws routes lazily in test, and Devise registers its Warden strategies from
  # the routes' devise_for, so the first request of a process would otherwise be
  # authenticated without them.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  let(:redirect_uri) { 'https://dashboard.example.org/' }
  let(:client) do
    Client.create!(name: 'Dashboard', app_id: 'dashboard', app_secret: 'unused', client_type: Client::PUBLIC,
                   redirect_uris: redirect_uri, scopes: 'class:researcher-read class:researcher-run packages:read')
  end
  let(:cohort)     { FactoryBot.create(:admin_cohort) }
  let(:project)    { FactoryBot.create(:project, cohorts: [cohort]) }
  let(:teacher)    { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)      { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
  let(:other)      { FactoryBot.create(:portal_clazz) }
  let(:researcher) do
    u = FactoryBot.create(:confirmed_user)
    u.add_role_for_project('researcher', project)
    u
  end
  let(:verifier)  { SecureRandom.urlsafe_base64(48) }
  let(:challenge) { Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false) }

  around(:each) do |example|
    old = ENV['REPORT_SERVER_URL']
    ENV['REPORT_SERVER_URL'] = 'https://report-server.example.org/'
    example.run
  ensure
    ENV['REPORT_SERVER_URL'] = old
  end

  def sign_in_as(user)
    sign_in user
  end

  def authorize(extra = {})
    get '/auth/oauth_authorize', params: {
      client_id: client.app_id, redirect_uri: redirect_uri, response_type: 'code', state: 'st4te',
      code_challenge: challenge, code_challenge_method: 'S256', context: "class:#{clazz.id}"
    }.merge(extra)
    Rack::Utils.parse_query(URI.parse(response.location).query)
  end

  def exchange(code, extra = {})
    post '/oauth/token', params: { grant_type: 'authorization_code', client_id: client.app_id, code: code,
                                   code_verifier: verifier, redirect_uri: redirect_uri }.merge(extra)
    JSON.parse(response.body)
  end

  def claims(token)
    JWT.decode(token, PortalSigningKey.private_key.public_key, true, algorithm: 'RS256', verify_aud: false)
  end

  def sign_out_all
    sign_out :user
    reset!
  end

  describe 'authorize' do
    before(:each) { sign_in_as(researcher) }

    it 'issues a code bound to the class for a researcher of it' do
      query = authorize
      expect(query['code']).to match(/\A[0-9a-f]{32}\z/)
      expect(query['state']).to eq('st4te')
      grant = AccessGrant.find_by(code: query['code'])
      expect(grant.context).to eq(type: 'class', id: clazz.id)
      expect(grant.scope_list).to eq(%w[class:researcher-read class:researcher-run packages:read])
      expect(grant.access_token).to be_nil
      expect(grant.refresh_token).to be_nil
    end

    it 'refuses a class the researcher may not open, with state, as it refuses a class that does not exist' do
      expect(authorize(context: "class:#{other.id}")).to eq('error' => 'access_denied', 'state' => 'st4te')
      expect(authorize(context: 'class:999999999')).to eq('error' => 'access_denied', 'state' => 'st4te')
    end

    it 'requires a context for a class-bound scope, and PKCE for a public client' do
      expect(authorize(context: nil)['error']).to eq('invalid_request')
      expect(authorize(code_challenge: nil, code_challenge_method: nil)['error']).to eq('invalid_request')
      expect(authorize(code_challenge_method: 'plain')['error']).to eq('invalid_request')
      expect(authorize(code_challenge: 'x' * 300)['error']).to eq('invalid_request')
      expect(authorize(code_challenge: 'not a challenge')['error']).to eq('invalid_request')
      expect(authorize(code_challenge: ['x' * 43])['error']).to eq('invalid_request')
    end

    it 'refuses a scope outside the client and the implicit flow for a scoped client' do
      expect(authorize(scope: 'portal-api')['error']).to eq('invalid_scope')
      get '/auth/oauth_authorize', params: { client_id: client.app_id, redirect_uri: redirect_uri, response_type: 'token', state: 's' }
      expect(Rack::Utils.parse_query(URI.parse(response.location).query)).to eq('error' => 'unauthorized_client', 'state' => 's')
    end

    it 'answers server_error when a requested capability has no configured audience' do
      ENV['REPORT_SERVER_URL'] = ''
      expect(authorize['error']).to eq('server_error')
      expect(authorize(scope: 'class:researcher-read')['code']).to be_present
    end

    it 'answers server_error, issuing no code, when the signing key is present but not a key' do
      key = ENV['PORTAL_SIGNING_KEY']
      ENV['PORTAL_SIGNING_KEY'] = 'not a pem'
      expect { expect(authorize).to eq('error' => 'server_error', 'state' => 'st4te') }.not_to change { AccessGrant.count }
    ensure
      ENV['PORTAL_SIGNING_KEY'] = key
    end

    it 'answers server_error, issuing no code, when the signing key is not configured' do
      key = ENV.delete('PORTAL_SIGNING_KEY')
      expect { expect(authorize).to eq('error' => 'server_error', 'state' => 'st4te') }.not_to change { AccessGrant.count }
    ensure
      ENV['PORTAL_SIGNING_KEY'] = key
    end
  end

  describe 'token' do
    before(:each) { sign_in_as(researcher) }

    it 'exchanges the code once for an RS256 access token and leaves no grant behind' do
      code = authorize['code']
      body = exchange(code)
      expect(body.keys).to match_array(%w[access_token token_type expires_in scope])
      expect(response.headers['Cache-Control']).to include('no-store')
      expect(body).to include('token_type' => 'Bearer', 'expires_in' => 7200,
                              'scope' => 'class:researcher-read class:researcher-run packages:read')
      data, header = claims(body['access_token'])
      expect(header).to include('typ' => 'at+jwt', 'kid' => PortalSigningKey.kid, 'alg' => 'RS256')
      expect(data).to include('iss' => APP_CONFIG[:site_url], 'sub' => researcher.id.to_s, 'uid' => researcher.id,
                              'client_id' => 'dashboard', 'context' => { 'type' => 'class', 'id' => clazz.id },
                              'aud' => [APP_CONFIG[:site_url], 'https://report-server.example.org'])
      expect(data.keys).not_to include('is_admin', 'user_type', 'scope_kind', 'scope_id')
      expect(AccessGrant.where(client_id: client.id)).to be_empty

      expect(exchange(code)).to eq('error' => 'invalid_grant')
      expect(response.status).to eq(400)
      expect(response.headers['Cache-Control']).to include('no-store')
    end

    it 'leaves the code redeemable when signing fails, rather than spending it' do
      code = authorize['code']
      allow(SignedJwt).to receive(:create_access_token).and_raise(SignedJwt::Error, 'boom')
      expect(exchange(code)).to eq('error' => 'server_error')
      expect(response.status).to eq(500)
      allow(SignedJwt).to receive(:create_access_token).and_call_original
      expect(exchange(code)['access_token']).to be_present
    end

    it 'refuses a wrong verifier, a different redirect_uri, another grant_type and an expired code' do
      expect(exchange(authorize['code'], code_verifier: 'x' * 43)).to eq('error' => 'invalid_grant')
      expect(exchange(authorize['code'], redirect_uri: 'https://dashboard.example.org/other')).to eq('error' => 'invalid_grant')
      expect(exchange(authorize['code'], grant_type: 'refresh_token')).to eq('error' => 'unsupported_grant_type')
      code = authorize['code']
      travel(AccessGrant::CodeExpireTime + 1.second) { expect(exchange(code)).to eq('error' => 'invalid_grant') }
    end

    it 'accepts POST only, and answers CORS for the token endpoint' do
      expect { get '/oauth/token' }.to raise_error(ActionController::RoutingError)
      options '/oauth/token', headers: { 'Origin' => 'https://dashboard.example.org', 'Access-Control-Request-Method' => 'POST' }
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end

  describe 'the offering launch route' do
    let(:report) do
      FactoryBot.create(:external_report, client: client, report_type: ExternalReport::ClassReport,
                        supports_researchers: true, url: redirect_uri)
    end
    let(:offering) { FactoryBot.create(:portal_offering, clazz: clazz) }

    it "never launches a scoped client's report with a token in its URL" do
      sign_in_as(teacher.user)
      expect {
        expect { get "/portal/offerings/#{offering.id}/external_report/#{report.id}" }.to raise_error(ActionController::RoutingError)
      }.not_to change { AccessGrant.count }
    end
  end

  describe 'using the token' do
    let(:token) do
      sign_in_as(researcher)
      t = exchange(authorize['code'])['access_token']
      sign_out_all
      t
    end
    let(:bearer) { { 'Authorization' => "Bearer #{token}" } }
    let(:firebase_app) { FactoryBot.create(:firebase_app) }

    it 'mints a Firebase researcher token for its own class and no other' do
      get '/api/v1/jwt/firebase', params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: clazz.class_hash }, headers: bearer
      expect(response.status).to eq(201)
      get '/api/v1/jwt/firebase', params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: other.class_hash }, headers: bearer
      expect(response.status).to eq(400)
    end

    it 'is refused wherever no capability it holds is declared' do
      get '/api/v1/jwt/firebase', params: { firebase_app: firebase_app.name }, headers: bearer
      expect(response.status).to eq(403)
      post '/api/v1/jwt/firebase', params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: clazz.class_hash }, headers: bearer
      expect(response.status).to eq(403)
      post '/api/v1/jwt/portal', headers: bearer
      expect(response.status).to eq(403)
      get '/api/v1/research_classes', headers: bearer
      expect(response.status).to eq(403)
      get '/auth/user', headers: bearer
      expect(response.status).to eq(403)
    end

    it 'never becomes a session' do
      get '/api/v1/jwt/firebase', params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: clazz.class_hash }, headers: bearer
      get '/auth/user'
      expect(response).to redirect_to('/auth/login')
    end

    it 'keeps its ceiling on a request that also carries a session' do
      sign_in_as(researcher)
      get '/auth/user', headers: bearer
      expect(response.status).to eq(403)
    end
  end
end
