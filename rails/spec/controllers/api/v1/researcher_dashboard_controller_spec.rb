require 'spec_helper'

describe API::V1::ResearcherDashboardController, type: :controller do
  include_context 'with the researcher dashboard configured'

  let(:read_capability) { TokenCapabilities::CLASS_RESEARCHER_READ }
  let(:run_capability)  { TokenCapabilities::CLASS_RESEARCHER_RUN }

  let(:project)    { FactoryBot.create(:project) }
  let(:cohort)     { FactoryBot.create(:admin_cohort, name: 'Cohort A', project: project) }
  let(:teacher)    { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)      { FactoryBot.create(:portal_clazz, name: 'Class A', teachers: [teacher]) }
  let(:other_clazz) { FactoryBot.create(:portal_clazz, teachers: [FactoryBot.create(:portal_teacher)]) }
  let(:activity)   { FactoryBot.create(:external_activity, name: 'Moth 1.2', url: 'HTTPS://ap.example:443/?activity=1', tool: FactoryBot.create(:ap_tool)) }
  let!(:offering)  { FactoryBot.create(:portal_offering, clazz: clazz, runnable: activity) }
  let(:researcher) {
    user = FactoryBot.create(:confirmed_user)
    user.add_role_for_project('researcher', project)
    user
  }

  def token_for(user, capabilities: [read_capability, run_capability], context_clazz: clazz, ttl: 3600)
    SignedJwt.create_access_token(user, client_id: 'researcher-dashboard', capabilities: capabilities,
                                  context: context_clazz && { type: 'class', id: context_clazz.id },
                                  audiences: [APP_CONFIG[:site_url]], expires_in: ttl)
  end

  def bearer(token)
    request.headers['Authorization'] = "Bearer #{token}"
  end

  # A controller spec reuses one request environment, and Warden memoizes both the user it
  # authenticated and the strategy instances that ran, so a second call in one example has
  # to start from nothing for its own bearer to be read.
  def reset_credential
    sign_out(:user)
    warden.clear_strategies_cache!
    Current.reset
  end

  def json
    JSON.parse(response.body)
  end

  def keys_anywhere(value)
    case value
    when Hash then value.keys + value.values.flat_map { |v| keys_anywhere(v) }
    when Array then value.flat_map { |v| keys_anywhere(v) }
    else []
    end
  end

  before(:each) { Current.reset }

  describe 'GET scope' do
    def get_scope
      get :scope, format: :json
    end

    context 'with an access token scoped to the class' do
      before(:each) { bearer(token_for(researcher)) }

      it 'describes the class in the token' do
        get_scope
        expect(response.status).to eq(200)
        expect(json.keys).to match_array(%w[kind id name class_hash platform_user_id teachers cohorts project_ids assignment_fingerprint assignments])
        expect(json).to include(
          'kind' => 'class',
          'id' => clazz.id,
          'name' => 'Class A',
          'class_hash' => clazz.class_hash,
          'platform_user_id' => researcher.id,
          'teachers' => [{ 'id' => teacher.user_id, 'name' => "#{teacher.user.first_name} #{teacher.user.last_name}" }],
          'cohorts' => [{ 'id' => cohort.id, 'name' => 'Cohort A' }],
          'project_ids' => [project.id],
          'assignment_fingerprint' => ResearcherDashboard::Scope.new(clazz).fingerprint,
          'assignments' => [{
            'offering_id' => offering.id, 'runnable_id' => activity.id, 'name' => 'Moth 1.2',
            'url' => 'HTTPS://ap.example:443/?activity=1', 'tool' => 'Activity Player'
          }]
        )
      end

      it 'carries no platform field and no credential' do
        get_scope
        expect(keys_anywhere(json)).not_to include('platform')
        expect(response.body).not_to include('eyJ')
      end
    end

    it 'answers for the class in the token, never for another the researcher may open' do
      second = FactoryBot.create(:portal_clazz, name: 'Class B', teachers: [teacher])
      bearer(token_for(researcher, context_clazz: second))
      get_scope
      expect(response.status).to eq(200)
      expect(json).to include('id' => second.id, 'name' => 'Class B')
    end

    context 'refusing with 401' do
      it 'without a credential' do
        get_scope
        expect(response.status).to eq(401)
      end

      it 'for an expired access token' do
        bearer(token_for(researcher, ttl: -60))
        get_scope
        expect(response.status).to eq(401)
      end

      it 'for an unscoped HS256 portal token for the same user' do
        bearer(SignedJwt.create_portal_token(researcher, {}, 3600))
        get_scope
        expect(response.status).to eq(401)
        expect(json['message']).to match(/accept only a Researcher Dashboard access token/)
      end

      it 'for a session with no bearer' do
        sign_in researcher
        get_scope
        expect(response.status).to eq(401)
        expect(json['message']).to match(/accept only a Researcher Dashboard access token/)
      end

      [SignedJwt::AUD_REPORT_SERVER, SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS].each do |aud|
        it "for a #{aud} assertion" do
          bearer(SignedJwt.create_assertion(researcher, aud: aud, expires_in: 60))
          get_scope
          expect(response.status).to eq(401)
        end
      end
    end

    context 'refusing with 403' do
      it 'a token carrying no context' do
        bearer(token_for(researcher, context_clazz: nil))
        get_scope
        expect(response.status).to eq(403)
        expect(json['message']).to match(/not bound to a class/)
      end

      it 'a token that does not carry class:researcher-read' do
        bearer(token_for(researcher, capabilities: [run_capability]))
        get_scope
        expect(response.status).to eq(403)
        expect(json).to include('success' => false, 'response_type' => 'ERROR')
      end

      it 'a service-minted portal-api token' do
        bearer(token_for(researcher, capabilities: [TokenCapabilities::PORTAL_API]))
        get_scope
        expect(response.status).to eq(403)
      end

      it 'a user who may not research the class the token names' do
        bearer(token_for(FactoryBot.create(:confirmed_user)))
        get_scope
        expect(response.status).to eq(403)
        expect(json['message']).to match(/do not have access/)
      end

      it 'a researcher whose grant has expired since the token was minted' do
        token = token_for(researcher)
        researcher.project_users.update_all(expiration_date: Time.now - 1.day)
        bearer(token)
        get_scope
        expect(response.status).to eq(403)
      end
    end

    it 'answers 404 when the scoped class has been deleted' do
      token = token_for(researcher)
      clazz.destroy
      bearer(token)
      get_scope
      expect(response.status).to eq(404)
      expect(json['message']).to match(/no longer exists/)
    end
  end

  describe 'POST refresh_profile' do
    let(:derive_url) { 'https://functions.example/researcherDashboard/derive-profile' }
    let(:warnings) { [] }

    before(:each) do
      allow(Rails.logger).to receive(:warn).and_call_original
      allow(Rails.logger).to receive(:warn).with(/researcher_dashboard\.upstream_refusal/) { |message| warnings << message }
    end

    def refresh
      post :refresh_profile, format: :json
    end

    context 'with an access token scoped to the class' do
      before(:each) { bearer(token_for(researcher)) }

      it 'posts the URLs to the deriver and answers 202 with the fingerprint' do
        posted = nil
        stub_request(:post, derive_url).to_return { |request|
          posted = request
          { status: 202, body: '{"success":true,"queued":true}', headers: { 'Content-Type' => 'application/json' } }
        }
        refresh
        fingerprint = ResearcherDashboard::Scope.new(clazz).fingerprint
        expect(response.status).to eq(202)
        expect(json).to eq('queued' => true, 'assignment_fingerprint' => fingerprint)
        expect(JSON.parse(posted.body)).to eq(
          'class_hash' => clazz.class_hash,
          'assignment_fingerprint' => fingerprint,
          'assignment_urls' => ['HTTPS://ap.example:443/?activity=1']
        )
        assertion = posted.headers['Authorization'].sub(/\ABearer /, '')
        data = JWT.decode(assertion, PortalSigningKey.private_key.public_key, true,
                          algorithm: 'RS256', aud: SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS, verify_aud: true).first
        expect(data['uid']).to eq(researcher.id)
      end

      it "answers 502 with the function's reason when it refuses" do
        stub_request(:post, derive_url).to_return(status: 400, body: '{"success":false,"error":"assignment_urls[3] is too long"}',
                                                  headers: { 'Content-Type' => 'application/json' })
        refresh
        expect(response.status).to eq(502)
        expect(json['message']).to eq('report-service refused the profile refresh: assignment_urls[3] is too long')
        expect(json['details']).to eq('upstream' => 'report-service', 'status' => 400, 'reason' => 'assignment_urls[3] is too long')
      end

      it "passes the function's 503 through as a 502" do
        stub_request(:post, derive_url).to_return(status: 503, body: '{"success":false,"error":"RD_AUTHORING_HOSTS is not set"}',
                                                  headers: { 'Content-Type' => 'application/json' })
        refresh
        expect(response.status).to eq(502)
        expect(json['details']).to include('status' => 503, 'reason' => 'RD_AUTHORING_HOSTS is not set')
      end

      it 'answers 504 for a read timeout' do
        stub_request(:post, derive_url).to_raise(Net::ReadTimeout)
        refresh
        expect(response.status).to eq(504)
      end

      [Errno::ECONNREFUSED, EOFError].each do |error|
        it "answers 502 for #{error}" do
          stub_request(:post, derive_url).to_raise(error)
          refresh
          expect(response.status).to eq(502)
          expect(json['message']).to eq('report-service could not be reached')
        end
      end

      it 'logs each upstream failure once, without the assertion' do
        stub_request(:post, derive_url).to_raise(Net::ReadTimeout)
        refresh
        expect(warnings.size).to eq(1)
        expect(warnings.first).not_to include('eyJ')
      end

      it 'answers 503 naming the unset function URL, and sends nothing' do
        ENV.delete('RESEARCHER_DASHBOARD_FUNCTION_URL')
        refresh
        expect(response.status).to eq(503)
        expect(json['message']).to match(/RESEARCHER_DASHBOARD_FUNCTION_URL is not set/)
        expect(a_request(:any, /.*/)).not_to have_been_made
      end

      it 'answers 503 naming the signing key when the portal cannot sign, and sends nothing' do
        previous = ENV.slice('PORTAL_SIGNING_KEY', 'PORTAL_PREVIOUS_VERIFY_KEYS')
        # The presented token still verifies, through the rotation map, so the refusal can
        # only be the signing key the assertion needs.
        ENV['PORTAL_PREVIOUS_VERIFY_KEYS'] = JSON.generate(PortalSigningKey.kid => PortalSigningKey.private_key.public_key.to_pem)
        ENV['PORTAL_SIGNING_KEY'] = ''
        refresh
        expect(response.status).to eq(503)
        expect(json['message']).to match(/PORTAL_SIGNING_KEY is not usable/)
        expect(a_request(:any, /.*/)).not_to have_been_made
      ensure
        ENV['PORTAL_SIGNING_KEY'] = previous['PORTAL_SIGNING_KEY']
        ENV['PORTAL_PREVIOUS_VERIFY_KEYS'] = previous['PORTAL_PREVIOUS_VERIFY_KEYS']
      end

      it 'answers 422 for an oversized list, and sends nothing' do
        allow_any_instance_of(ResearcherDashboard::Scope).to receive(:assignments).and_return(
          (1..501).map { |i| { offering_id: i, runnable_id: i, name: 'x', url: "https://a.example/#{i}", tool: nil } }
        )
        refresh
        expect(response.status).to eq(422)
        expect(a_request(:any, /.*/)).not_to have_been_made
      end
    end

    it 'refreshes the class in the token, never another' do
      second = FactoryBot.create(:portal_clazz, teachers: [teacher])
      bearer(token_for(researcher, context_clazz: second))
      stub_request(:post, derive_url).to_return(status: 202, body: '{"queued":true}', headers: { 'Content-Type' => 'application/json' })
      refresh
      expect(response.status).to eq(202)
      expect(a_request(:post, derive_url).with { |r| JSON.parse(r.body)['class_hash'] == second.class_hash }).to have_been_made.once
    end

    it 'refuses a non-researcher with 403, and sends nothing' do
      bearer(token_for(FactoryBot.create(:confirmed_user)))
      refresh
      expect(response.status).to eq(403)
      expect(json['message']).to eq('You do not have access to this class as a researcher')
      expect(a_request(:any, /.*/)).not_to have_been_made
    end

    it 'refuses a token without class:researcher-read with 403, and sends nothing' do
      bearer(token_for(researcher, capabilities: [run_capability]))
      refresh
      expect(response.status).to eq(403)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end

    it 'refuses a session with no bearer with 401' do
      sign_in researcher
      refresh
      expect(response.status).to eq(401)
    end
  end

  describe 'POST run_package' do
    let(:run_url) { 'https://functions.example/researcherDashboard/run-package' }
    let(:package) { { 'identity' => 'projects/20/b', 'version' => '1.0.0' } }
    let(:queue) { [{ 'class_hash' => clazz.class_hash, 'package_key' => 'projects-20-b' }] }

    before(:each) do
      FirebaseTestHelper.create_test_firebase_app(name: 'report-service-dev')
      stub_request(:get, 'https://report-server.example/api/v1/packages/resolve')
        .with(query: { identity: 'projects/20/b', version: '1.0.0' })
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: JSON.generate(
          identity: 'projects/20/b', version: '1.0.0', checksum: "sha256:#{'a' * 64}", catalog_id: 12,
          clue_prepull: false, archived: false, runnable: true, reason: nil
        ))
    end

    def run(body, content_type: 'application/json')
      request.headers['Content-Type'] = content_type
      post :run_package, body: body.is_a?(String) ? body : JSON.generate(body), format: :json
    end

    context 'with an access token scoped to the class' do
      before(:each) { bearer(token_for(researcher)) }

      it 'answers 202 with the queue state only, and no credential' do
        stub_request(:post, run_url).to_return(status: 202, headers: { 'Content-Type' => 'application/json' },
                                               body: JSON.generate(success: true, queue: queue, appended: ['projects-20-b'], vm: 'running', debug: 'x'))
        run({ 'packages' => [package] })
        expect(response.status).to eq(202)
        expect(json).to eq('queue' => queue, 'appended' => ['projects-20-b'], 'vm' => 'running')
        expect(response.body).not_to include('eyJ')
      end

      it 'refuses a checksum in the body with 400, and sends nothing' do
        run({ 'packages' => [package.merge('checksum' => "sha256:#{'b' * 64}")] })
        expect(response.status).to eq(400)
        expect(json['message']).to eq('packages[0] has unexpected keys: checksum')
        expect(a_request(:any, /.*/)).not_to have_been_made
      end

      it 'refuses a scope field in the body with 400' do
        run({ 'packages' => [package], 'class_id' => other_clazz.id })
        expect(response.status).to eq(400)
        expect(json['message']).to eq('Unexpected keys in the body: class_id')
      end

      it 'refuses malformed JSON with 400' do
        run('{"packages": [')
        expect(response.status).to eq(400)
        expect(json['message']).to eq('The body must be a JSON object')
      end

      it 'refuses a JSON array with 400' do
        run([package])
        expect(response.status).to eq(400)
      end

      it "answers the function's 409 with 409 and its reason" do
        stub_request(:post, run_url).to_return(status: 409, headers: { 'Content-Type' => 'application/json' },
                                               body: '{"success":false,"error":"queue at its cap (20 outstanding)"}')
        run({ 'packages' => [package] })
        expect(response.status).to eq(409)
        expect(json).to include('success' => false, 'response_type' => 'ERROR')
        expect(json['message']).to start_with('report-service refused the run')
        expect(json['details']).to eq('upstream' => 'report-service', 'status' => 409, 'reason' => 'queue at its cap (20 outstanding)')
      end

      it 'answers 503 naming an unset setting, and sends nothing' do
        ENV.delete('REPORT_SERVER_URL')
        run({ 'packages' => [package] })
        expect(response.status).to eq(503)
        expect(json['message']).to match(/REPORT_SERVER_URL is not set/)
        expect(a_request(:any, /.*/)).not_to have_been_made
      end
    end

    it 'runs against the class in the token, and forwards that token to the resolve' do
      stub_request(:post, run_url).to_return(status: 202, headers: { 'Content-Type' => 'application/json' },
                                             body: JSON.generate(queue: queue, appended: ['projects-20-b'], vm: 'launched'))
      token = token_for(researcher)
      bearer(token)
      run({ 'packages' => [package] })
      expect(response.status).to eq(202)
      expect(a_request(:post, run_url).with { |r| JSON.parse(r.body)['scope']['classes'] == [{ 'class_hash' => clazz.class_hash, 'class_id' => clazz.id }] })
        .to have_been_made.once
      expect(a_request(:get, /packages\/resolve/).with(headers: { 'Authorization' => "Bearer #{token}" })).to have_been_made.once
    end

    it 'gives two researchers of the same class their own answers and assertions' do
      second = FactoryBot.create(:confirmed_user)
      second.add_role_for_project('researcher', project)
      answers = { researcher.id => 1, second.id => 2 }
      key = PortalSigningKey.private_key.public_key
      stub_request(:post, run_url).to_return { |r|
        bearer_claims = JWT.decode(r.headers['Authorization'].sub(/\ABearer /, ''), key, true,
                                   algorithm: 'RS256', aud: SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS, verify_aud: true).first
        assertion = JWT.decode(JSON.parse(r.body)['report_server_assertion'], key, true,
                               algorithm: 'RS256', aud: SignedJwt::AUD_REPORT_SERVER, verify_aud: true).first
        expect(assertion['uid']).to eq(bearer_claims['uid'])
        { status: 202, headers: { 'Content-Type' => 'application/json' },
          body: JSON.generate(queue: [{ class_hash: clazz.class_hash, package_key: "p#{answers[bearer_claims['uid']]}" }], appended: [], vm: 'running') }
      }
      [researcher, second].each do |user|
        reset_credential
        bearer(token_for(user))
        run({ 'packages' => [package] })
        expect(response.status).to eq(202)
        expect(json['queue'].first['package_key']).to eq("p#{answers[user.id]}")
      end
      expect(a_request(:post, run_url)).to have_been_made.twice
    end

    it 'refuses a token without class:researcher-run with 403, and resolves nothing' do
      bearer(token_for(researcher, capabilities: [read_capability]))
      run({ 'packages' => [package] })
      expect(response.status).to eq(403)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end

    it 'refuses a non-researcher with 403, and resolves nothing' do
      bearer(token_for(FactoryBot.create(:confirmed_user)))
      run({ 'packages' => [package] })
      expect(response.status).to eq(403)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end

    it 'refuses a session with no bearer with 401' do
      sign_in researcher
      run({ 'packages' => [package] })
      expect(response.status).to eq(401)
    end
  end
end
