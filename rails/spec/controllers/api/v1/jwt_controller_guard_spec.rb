require 'spec_helper'

RSpec.describe API::V1::JwtController, type: :controller do
  before(:each) { generate_default_settings_with_mocks }
  after(:each) { Current.reset }

  let(:admin) do
    u = FactoryBot.create(:confirmed_user)
    u.add_role('admin')
    u
  end

  describe 'D1: OIDC service tokens are denied' do
    before(:each) do
      sign_in admin
      request.env['portal.auth_strategy'] = 'oidc_bearer_token'
    end

    it 'denies #portal even when the mapped user is an admin, and issues no token' do
      expect(SignedJwt).not_to receive(:create_portal_token)
      post :portal, params: { resource_link_id: 1, target_user_id: 2 }, format: :json
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to match(/does not accept OIDC service tokens/)
    end

    it 'denies #firebase even when the mapped user is an admin, and issues no token' do
      expect(SignedJwt).not_to receive(:create_firebase_token)
      post :firebase, params: { firebase_app: 'report-service-dev' }, format: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'D9: a service-minted token cannot be re-minted' do
    let(:teacher) { FactoryBot.create(:portal_teacher) }

    before(:each) do
      allow(controller).to receive(:current_user) do
        Current.minted_via_oidc_client_id = 99
        teacher.user
      end
      request.env['portal.auth_strategy'] = 'jwt_bearer_token'
    end

    it 'denies #portal and issues no token (holds even with a session present)' do
      expect(SignedJwt).not_to receive(:create_portal_token)
      post :portal, params: { as_teacher: 'true' }, format: :json
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to match(/may not be used to mint another token/)
    end

    it 'denies #firebase and issues no token' do
      expect(SignedJwt).not_to receive(:create_firebase_token)
      post :firebase, params: { firebase_app: 'report-service-dev' }, format: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'legitimate callers are unaffected' do
    let(:teacher) { FactoryBot.create(:portal_teacher) }

    it 'lets a session/portal-JWT teacher mint a portal token' do
      sign_in teacher.user
      post :portal, params: { as_teacher: 'true' }, format: :json
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['token']).to be_present
    end
  end

  describe 'marker hygiene' do
    let(:teacher) { FactoryBot.create(:portal_teacher) }

    it 'does not leak the marker between requests' do
      allow(controller).to receive(:current_user) do
        Current.minted_via_oidc_client_id = 5
        teacher.user
      end
      request.env['portal.auth_strategy'] = 'jwt_bearer_token'
      post :portal, params: { as_teacher: 'true' }, format: :json
      expect(response).to have_http_status(:forbidden)

      allow(controller).to receive(:current_user).and_return(teacher.user)
      post :portal, params: { as_teacher: 'true' }, format: :json
      expect(response).to have_http_status(:created)
    end
  end
end
