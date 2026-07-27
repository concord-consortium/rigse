require 'spec_helper'

# D11 rule 1: ApplicationController#confine_service_minted_tokens denies a marked (service-minted)
# token on any non-API controller. The marker is set by the jwt_bearer_token strategy when it honors
# a marked token; here we stub current_user to set it, matching what the strategy does at request time.
RSpec.describe HomeController, type: :controller do
  before(:each) { generate_default_settings_with_mocks }

  def stub_marked_token(client_id)
    allow(controller).to receive(:current_user) do
      Current.minted_via_oidc_client_id = client_id
      nil
    end
  end

  it 'denies a request carrying a service-minted token' do
    stub_marked_token(55)
    get :getting_started
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)['message']).to match(/service-minted token may only be used on the API/)
  end

  it 'does not deny a request with no marker' do
    get :getting_started
    expect(response).not_to have_http_status(:forbidden)
  end
end
