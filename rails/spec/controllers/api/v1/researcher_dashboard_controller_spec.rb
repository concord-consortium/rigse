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
end
