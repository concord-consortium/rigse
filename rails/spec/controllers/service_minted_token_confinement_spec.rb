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

# D11 rule 1 (API side): confine_service_minted_tokens short-circuits for API controllers
# (is_a?(API::APIController)) before touching auth, so a marked token is never denied on the
# pipeline's API endpoints. Asserted at the controller level (not via a request spec) so it verifies
# the request actually succeeds (200) rather than merely that the confinement message is absent — the
# latter would also hold for an unrelated 403. A controller spec runs the same inherited
# ApplicationController before_action chain, so it exercises the confinement filter deterministically,
# without the cold-boot first-request auth quirk of end-to-end bearer-token request specs.
RSpec.describe API::V1::OfferingsController, type: :controller do
  before(:each) { generate_default_settings_with_mocks }
  after(:each) { Current.reset }

  let(:teacher) { FactoryBot.create(:portal_teacher) }
  let(:offering) { FactoryBot.create(:portal_offering, clazz: teacher.clazzes.first) }

  it 'does not confine a marked token on an API controller' do
    # Set the marker exactly as the jwt_bearer_token strategy would when honoring a marked token.
    allow(controller).to receive(:current_user) do
      Current.minted_via_oidc_client_id = 77
      teacher.user
    end

    get :show, params: { id: offering.id }, format: :json

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to match(/service-minted token may only be used on the API/)
  end
end
