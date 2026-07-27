require 'spec_helper'

RSpec.describe API::V1::OidcMintController, type: :controller do
  let(:app_name) { 'report-service-dev' }
  let!(:firebase_app) { FirebaseTestHelper.create_test_firebase_app(name: app_name) }

  let(:mapped_user) { FactoryBot.create(:confirmed_user) }
  let(:oidc_sub) { 'google-sub-12345' }
  let!(:oidc_client) do
    Admin::OidcClient.create!(name: 'pipeline', sub: oidc_sub, user: mapped_user, can_mint_scoped_tokens: true)
  end

  let(:teacher) { FactoryBot.create(:portal_teacher) }
  let(:clazz) { teacher.clazzes.first }
  let(:student) { FactoryBot.create(:full_portal_student) }
  let(:offering) { FactoryBot.create(:portal_offering, clazz: clazz) }

  before(:each) do
    generate_default_settings_with_mocks
    clazz.students << student
    offering
    sign_in mapped_user
    request.env['portal.auth_strategy'] = 'oidc_bearer_token'
    request.env['portal.auth_client'] = oidc_client.name
    request.env['portal.auth_details'] = { sub: oidc_sub }
  end

  def firebase_token(claims_overrides: {}, app: app_name, expires_in: 3600, learner: student)
    claims = {
      platform_id: APP_CONFIG[:site_url],
      platform_user_id: learner.user.id,
      user_type: 'learner',
      class_hash: offering.clazz.class_hash,
      offering_id: offering.id
    }.merge(claims_overrides)
    SignedJwt.create_firebase_token(learner.user.id, app, expires_in, { claims: claims })
  end

  def decoded_token
    JSON.parse(response.body)['token'].then { |t| SignedJwt.decode_portal_token(t)[:data] }
  end

  describe 'authorization' do
    it 'mints for a client with can_mint_scoped_tokens true' do
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:created)
    end

    it 'denies a client with can_mint_scoped_tokens false' do
      oidc_client.update!(can_mint_scoped_tokens: false)
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:forbidden)
    end

    it 'denies a client that never set the flag (default false)' do
      Admin::OidcClient.where(id: oidc_client.id).update_all(can_mint_scoped_tokens: false)
      other = Admin::OidcClient.create!(name: 'legacy', sub: 'legacy-sub', user: mapped_user)
      request.env['portal.auth_details'] = { sub: other.sub }
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:forbidden)
    end

    it 'denies a non-OIDC caller' do
      request.env['portal.auth_strategy'] = 'jwt_bearer_token'
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'forwarded token validation' do
    it 'fails closed on a missing firebase_token' do
      post :create, params: { token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'fails closed on an invalid firebase_token' do
      post :create, params: { firebase_token: 'not-a-jwt', token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'surfaces the expired reason distinctly' do
      post :create, params: { firebase_token: firebase_token(expires_in: -3600), token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).dig('details', 'reason')).to eq('expired')
    end
  end

  describe 'learner minting' do
    it 'mints a learner token for the student named in the firebase token' do
      post :create, params: { firebase_token: firebase_token, token_type: 'learner' }, format: :json
      expect(response).to have_http_status(:created)
      claims = decoded_token
      expect(claims['user_type']).to eq('learner')
      expect(claims['uid']).to eq(student.user.id)
      expect(claims['offering_id']).to eq(offering.id)
      expect(claims['minted_via_oidc_client_id']).to eq(oidc_client.id)
      expect(claims['origin_offering_id']).to eq(offering.id)
      expect(claims['origin_class_hash']).to eq(clazz.class_hash)
    end
  end

  describe 'teacher minting' do
    it 'mints a teacher token for the origin class teacher' do
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:created)
      claims = decoded_token
      expect(claims['user_type']).to eq('teacher')
      expect(claims['uid']).to eq(teacher.user.id)
      expect(claims['teacher_id']).to eq(teacher.id)
      expect(claims['minted_via_oidc_client_id']).to eq(oidc_client.id)
    end

    it 'refuses an unrecognized token_type' do
      post :create, params: { firebase_token: firebase_token, token_type: 'user' }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'cross-class teacher minting' do
    let(:target_clazz) { FactoryBot.create(:portal_clazz) }

    it 'mints for a shared teacher of the target class' do
      target_clazz.teachers << teacher
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher', class_id: target_clazz.id }, format: :json
      expect(response).to have_http_status(:created)
      expect(decoded_token['teacher_id']).to eq(teacher.id)
    end

    it 'fails closed when the target class shares no teacher' do
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher', class_id: target_clazz.id }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'fails closed when the target class does not exist' do
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher', class_id: -1 }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'description audit label' do
    it 'defaults to (none) when absent' do
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      expect(decoded_token['minted_for']).to eq('(none)')
    end

    it 'strips CR/LF and caps length' do
      dirty = "line1\r\nline2" + ('x' * 200)
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher', description: dirty }, format: :json
      minted_for = decoded_token['minted_for']
      expect(minted_for).not_to match(/[\r\n]/)
      expect(minted_for.length).to eq(100)
    end

    it 'does not change the minted subject' do
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher', description: 'anything' }, format: :json
      expect(decoded_token['uid']).to eq(teacher.user.id)
    end
  end

  describe 'least-privileged teacher selection (Q2)' do
    let(:elevated_teacher) do
      t = FactoryBot.create(:portal_teacher)
      t.user.add_role('admin')
      t
    end

    it 'prefers a non-elevated teacher (lowest id) when the set is mixed' do
      clazz.teachers << elevated_teacher
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      non_elevated = [teacher, elevated_teacher].reject { |t| t.user.has_role?('admin') }.min_by(&:id)
      expect(decoded_token['teacher_id']).to eq(non_elevated.id)
    end

    it 'still mints for the lowest-id elevated teacher when all are elevated' do
      teacher.user.add_role('manager')
      another_elevated = elevated_teacher
      clazz.teachers << another_elevated
      post :create, params: { firebase_token: firebase_token, token_type: 'teacher' }, format: :json
      expect(response).to have_http_status(:created)
      lowest = [teacher, another_elevated].min_by(&:id)
      expect(decoded_token['teacher_id']).to eq(lowest.id)
    end
  end
end
