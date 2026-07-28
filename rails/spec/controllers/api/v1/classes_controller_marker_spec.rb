require 'spec_helper'

# D9 propagation: any portal token created while acting under a service-minted token inherits the
# marker at the create_portal_token choke point. classes#log_links is an API-namespace issuer, so D11
# does not deny it; the issued token must still carry minted_via_oidc_client_id.
RSpec.describe API::V1::ClassesController, type: :controller do
  before(:each) { generate_default_settings_with_mocks }
  after(:each) { Current.reset }

  let(:admin) do
    u = FactoryBot.create(:confirmed_user)
    u.add_role('admin')
    u
  end
  let(:clazz) { FactoryBot.create(:portal_offering).clazz }

  it 'propagates the mint marker into the token log_links issues' do
    clazz
    allow(controller).to receive(:current_user) do
      Current.minted_via_oidc_client_id = 77
      admin
    end

    get :log_links, params: { id: clazz.id }, format: :json

    expect(response).to have_http_status(:ok)
    url = JSON.parse(response.body)['offerings'].first['links']['download']
    token = Rack::Utils.parse_query(URI(url).query)['portal_token']
    decoded = SignedJwt.decode_portal_token(token)[:data]
    expect(decoded['minted_via_oidc_client_id']).to eq(77)
  end
end
