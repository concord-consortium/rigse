require 'spec_helper'

describe API::V1::ResearcherDashboardController, type: :controller do
  include_context 'with the researcher dashboard configured'

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
  let(:scope_claims) { { scope_kind: 'class', scope_id: clazz.id } }

  def token_for(user, claims: scope_claims, ttl: 3600, aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)
    SignedJwt.create_portal_token(user, { user_type: 'researcher' }.merge(claims), ttl, aud: aud)
  end

  def bearer(token)
    request.headers['Authorization'] = "Bearer #{token}"
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

  describe 'GET clazz' do
    def get_clazz(id = clazz.id)
      get :clazz, params: { id: id }, format: :json
    end

    context 'with a launch token for the class' do
      before(:each) { bearer(token_for(researcher)) }

      it 'describes the class' do
        get_clazz
        expect(response.status).to eq(200)
        expect(json.keys).to match_array(%w[id name class_hash platform_user_id teachers cohorts project_ids assignment_fingerprint assignments])
        expect(json).to include(
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
        get_clazz
        expect(keys_anywhere(json)).not_to include('platform')
        expect(response.body).not_to include('eyJ')
      end

      it 'refuses another class with 403' do
        get_clazz(other_clazz.id)
        expect(response.status).to eq(403)
        expect(json['message']).to match(/not the class this token was issued for/)
      end
    end

    context 'refusing with 401' do
      it 'without a bearer' do
        get_clazz
        expect(response.status).to eq(401)
      end

      it 'for an expired launch token' do
        bearer(token_for(researcher, ttl: -60))
        get_clazz
        expect(response.status).to eq(401)
        expect(json['message']).to match(/Launch the Researcher Dashboard again/)
      end

      it 'for a legacy HS256 portal token for the same user' do
        bearer(SignedJwt.create_portal_token(researcher, {}, 3600))
        get_clazz
        expect(response.status).to eq(401)
      end

      it 'for a session with no bearer' do
        sign_in researcher
        get_clazz
        expect(response.status).to eq(401)
        expect(json['message']).to match(/accepts only a Researcher Dashboard launch token/)
      end

      [SignedJwt::AUD_REPORT_SERVER, SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS].each do |aud|
        it "for a #{aud} token" do
          bearer(token_for(researcher, aud: aud))
          get_clazz
          expect(response.status).to eq(401)
        end
      end
    end

    context 'refusing with 403' do
      it 'a scope kind other than class' do
        bearer(token_for(researcher, claims: { scope_kind: 'cohort', scope_id: clazz.id }))
        get_clazz
        expect(response.status).to eq(403)
        expect(json['message']).to match(/scope kind/)
      end

      it 'a user who may not research the class' do
        bearer(token_for(FactoryBot.create(:confirmed_user)))
        get_clazz
        expect(response.status).to eq(403)
        expect(json['message']).to match(/do not have access/)
      end

      it 'a researcher whose grant has expired since the token was minted' do
        token = token_for(researcher)
        researcher.project_users.update_all(expiration_date: Time.now - 1.day)
        bearer(token)
        get_clazz
        expect(response.status).to eq(403)
      end
    end

    context 'refusing with 404' do
      it 'when the scoped class has been deleted' do
        bearer(token_for(researcher))
        clazz.destroy
        get_clazz
        expect(response.status).to eq(404)
        expect(json['message']).to match(/no longer exists/)
      end

      it 'when the dashboard is disabled' do
        bearer(token_for(researcher))
        ENV.delete('RESEARCHER_DASHBOARD_URL')
        get_clazz
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'POST refresh_profile' do
    let(:derive_url) { 'https://functions.example/researcherDashboard/derive-profile' }
    let(:warnings) { [] }

    before(:each) do
      allow(Rails.logger).to receive(:warn).and_call_original
      allow(Rails.logger).to receive(:warn).with(/researcher_dashboard\.upstream_refusal/) { |message| warnings << message }
    end

    def refresh(id = clazz.id)
      post :refresh_profile, params: { id: id }, format: :json
    end

    context 'with a launch token for the class' do
      let(:token) { token_for(researcher) }
      before(:each) { bearer(token) }

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
        data = SignedJwt.decode_portal_token(assertion, aud: SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS)[:data]
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

      it 'answers 422 for an oversized list, and sends nothing' do
        allow_any_instance_of(ResearcherDashboard::Scope).to receive(:assignments).and_return(
          (1..501).map { |i| { offering_id: i, runnable_id: i, name: 'x', url: "https://a.example/#{i}", tool: nil } }
        )
        refresh
        expect(response.status).to eq(422)
        expect(a_request(:any, /.*/)).not_to have_been_made
      end
    end

    it 'refuses a class other than the scoped one with 403, and sends nothing' do
      bearer(token_for(researcher))
      refresh(other_clazz.id)
      expect(response.status).to eq(403)
      expect(json['message']).to eq('The requested class is not the class this token was issued for')
      expect(a_request(:any, /.*/)).not_to have_been_made
    end

    it 'refuses a non-researcher with 403, and sends nothing' do
      bearer(token_for(FactoryBot.create(:confirmed_user)))
      refresh
      expect(response.status).to eq(403)
      expect(json['message']).to eq('You do not have access to this class as a researcher')
      expect(a_request(:any, /.*/)).not_to have_been_made
    end

    it 'answers 404 when the dashboard is disabled, and sends nothing' do
      bearer(token_for(researcher))
      ENV.delete('RESEARCHER_DASHBOARD_URL')
      refresh
      expect(response.status).to eq(404)
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

    context 'with a launch token for the class' do
      before(:each) { bearer(token_for(researcher)) }

      it 'answers 202 with the queue state only, and no credential' do
        stub_request(:post, run_url).to_return(status: 202, headers: { 'Content-Type' => 'application/json' },
                                               body: JSON.generate(success: true, queue: queue, appended: ['projects-20-b'], vm: 'running', debug: 'x'))
        run({ 'packages' => [package] })
        expect(response.status).to eq(202)
        expect(json).to eq('queue' => queue, 'appended' => ['projects-20-b'], 'vm' => 'running')
        expect(response.body).not_to include('eyJ')
      end

      it 'posts the class the token is scoped to' do
        stub_request(:post, run_url).to_return(status: 202, headers: { 'Content-Type' => 'application/json' },
                                               body: JSON.generate(queue: queue, appended: ['projects-20-b'], vm: 'launched'))
        run({ 'packages' => [package] })
        expect(a_request(:post, run_url).with { |r| JSON.parse(r.body)['scope']['classes'] == [{ 'class_hash' => clazz.class_hash, 'class_id' => clazz.id }] })
          .to have_been_made.once
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

    it 'gives two researchers of the same class their own answers and assertions' do
      second = FactoryBot.create(:confirmed_user)
      second.add_role_for_project('researcher', project)
      answers = { researcher.id => 1, second.id => 2 }
      stub_request(:post, run_url).to_return { |r|
        uid = SignedJwt.decode_portal_token(r.headers['Authorization'].sub(/\ABearer /, ''), aud: SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS)[:data]['uid']
        assertion = SignedJwt.decode_portal_token(JSON.parse(r.body)['report_server_assertion'], aud: SignedJwt::AUD_REPORT_SERVER)[:data]
        expect(assertion['uid']).to eq(uid)
        { status: 202, headers: { 'Content-Type' => 'application/json' },
          body: JSON.generate(queue: [{ class_hash: clazz.class_hash, package_key: "p#{answers[uid]}" }], appended: [], vm: 'running') }
      }
      [researcher, second].each do |user|
        Current.reset
        bearer(token_for(user))
        run({ 'packages' => [package] })
        expect(response.status).to eq(202)
        expect(json['queue'].first['package_key']).to eq("p#{answers[user.id]}")
      end
      expect(a_request(:post, run_url)).to have_been_made.twice
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

    it 'answers 404 when the dashboard is disabled' do
      bearer(token_for(researcher))
      ENV.delete('RESEARCHER_DASHBOARD_URL')
      run({ 'packages' => [package] })
      expect(response.status).to eq(404)
    end
  end
end
