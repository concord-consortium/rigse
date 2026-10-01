require 'spec_helper'

# A scoped token (every service-minted one is) or an access token never becomes a Rails session,
# so it cannot be traded for a cookie that outlives it; an unscoped portal JWT does.
RSpec.describe 'D10: a scoped token or an access token never becomes a session', type: :request do
  # Rails 8 draws routes lazily in test, and Devise registers its Warden strategies from
  # the routes, so the first request of a process would otherwise run without them.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  let(:user) { FactoryBot.create(:confirmed_user) }

  # An API action that accepts portal-api and authenticates through Devise, so Warden asks
  # the strategy whether to store the user; it refuses a non-teacher only afterwards.
  def authenticate_on_the_api(token)
    get '/api/v1/teacher_classes/1', headers: { 'Authorization' => "Bearer #{token}" }
  end

  it 'does not establish a session from a minted token' do
    authenticate_on_the_api(ServiceMintedTokenHelper.minted_token(user, oidc_client_id: 5))
    expect(response.status).not_to eq(401)
    get '/auth/user'
    expect(response).to redirect_to('/auth/login')
  end

  it 'does not establish a session from the portal-api scope without the marker' do
    authenticate_on_the_api(ServiceMintedTokenHelper.unmarked_portal_api_token(user))
    expect(response.status).not_to eq(401)
    get '/auth/user'
    expect(response).to redirect_to('/auth/login')
  end

  it 'does not establish a session from an unscoped access token' do
    token = SignedJwt.create_access_token(user, client_id: 'spa', capabilities: nil, context: nil,
                                          audiences: [APP_CONFIG[:site_url]], expires_in: 600)
    authenticate_on_the_api(token)
    expect(response.status).not_to eq(401)
    get '/auth/user'
    expect(response).to redirect_to('/auth/login')
  end

  it 'still establishes a session from an unscoped portal JWT' do
    authenticate_on_the_api(SignedJwt.create_portal_token(user))
    expect(response.status).not_to eq(401)
    get '/auth/user'
    expect(response.status).to eq(200)
  end
end
