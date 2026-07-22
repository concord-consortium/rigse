require 'spec_helper'

RSpec.describe Admin::OidcClientsController, type: :controller do
  let(:admin_user) { FactoryBot.generate(:admin_user) }
  let(:mapped_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in admin_user
  end

  describe '#edit' do
    render_views

    it 'renders the form for a client with NULL capabilities without raising' do
      client = Admin::OidcClient.create!(name: 'Legacy', sub: 'legacy-sub', user: mapped_user)
      client.update_column(:capabilities, nil)

      get :edit, params: { id: client.id }

      expect(response).to have_http_status(:ok)
      Admin::OidcClient::CAPABILITIES.each_key do |identifier|
        expect(response.body).to include("capability_#{identifier}")
      end
    end
  end

  describe '#update' do
    it 'persists checked capabilities' do
      client = Admin::OidcClient.create!(name: 'Client', sub: 'sub-1', user: mapped_user)

      put :update, params: {
        id: client.id,
        admin_oidc_client: {
          name: 'Client', sub: 'sub-1', user_id: mapped_user.id,
          capabilities: ['enroll_student', 'update_offering_state']
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(client.reload.capabilities).to match_array(['enroll_student', 'update_offering_state'])
    end

    it 'clears capabilities when none are checked (hidden-field sentinel only)' do
      client = Admin::OidcClient.create!(name: 'Client', sub: 'sub-2', user: mapped_user, capabilities: ['enroll_student'])

      put :update, params: {
        id: client.id,
        admin_oidc_client: {
          name: 'Client', sub: 'sub-2', user_id: mapped_user.id,
          capabilities: ['']
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(client.reload.capabilities).to eq([])
    end

    it 'permits requires_forwarded_jwt' do
      client = Admin::OidcClient.create!(name: 'Client', sub: 'sub-3', user: mapped_user)

      put :update, params: {
        id: client.id,
        admin_oidc_client: {
          name: 'Client', sub: 'sub-3', user_id: mapped_user.id,
          requires_forwarded_jwt: '1'
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(client.reload.requires_forwarded_jwt).to be true
    end
  end
end
