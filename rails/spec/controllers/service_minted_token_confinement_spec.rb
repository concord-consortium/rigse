require 'spec_helper'

# ApplicationController#enforce_token_capabilities refuses a portal-api token on a controller
# outside the API, since such a controller declares no capability.
RSpec.describe HomeController, type: :controller do
  before(:each) { generate_default_settings_with_mocks }

  after(:each) { Current.reset }

  let(:user) { FactoryBot.create(:confirmed_user) }

  def present(token)
    Current.reset
    request.headers['Authorization'] = "Bearer #{token}"
  end

  it 'denies a request carrying a service-minted token' do
    present(PortalTokenHelper.minted_token(user, oidc_client_id: 55))
    get :getting_started
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)['message']).to match(/may not be used here/)
  end

  it 'denies the portal-api scope without the marker' do
    present(PortalTokenHelper.unmarked_portal_api_token(user))
    get :getting_started
    expect(response).to have_http_status(:forbidden)
  end

  it 'does not deny a request with no token' do
    get :getting_started
    expect(response).not_to have_http_status(:forbidden)
  end
end

# API::APIController declares portal-api, so a minted token reaches the API. The spec asserts a 200,
# since an unrelated 403 would also lack the refusal message.
RSpec.describe API::V1::OfferingsController, type: :controller do
  before(:each) { generate_default_settings_with_mocks }
  after(:each) { Current.reset }

  let(:teacher) { FactoryBot.create(:portal_teacher) }
  let(:offering) { FactoryBot.create(:portal_offering, clazz: teacher.clazzes.first) }

  it 'does not confine a minted token on an API controller' do
    token = PortalTokenHelper.minted_token(teacher.user, oidc_client_id: 77)
    Current.reset
    request.headers['Authorization'] = "Bearer #{token}"

    get :show, params: { id: offering.id }, format: :json

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to match(/may not be used here/)
  end
end
