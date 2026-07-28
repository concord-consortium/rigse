require 'spec_helper'

# The mint lives in its own controller (API::V1::OidcMintController) but is mounted under the jwt
# namespace via an absolute controller target: `post 'oidc_mint', to: '/api/v1/oidc_mint#create'`.
# That leading-slash target is what keeps it on OidcMintController rather than an implied
# API::V1::Jwt::OidcMintController; a namespace-relative or bare `post :oidc_mint` would silently
# retarget it. Pin the resolution so a future routes refactor cannot break the endpoint unnoticed.
RSpec.describe 'OIDC scoped-token mint routing', type: :routing do
  it 'routes POST /api/v1/jwt/oidc_mint to API::V1::OidcMintController#create' do
    expect(post: '/api/v1/jwt/oidc_mint').to route_to(
      controller: 'api/v1/oidc_mint',
      action: 'create',
      format: :json
    )
  end
end
