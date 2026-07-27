require 'spec_helper'

# D11 rule 1 (API side): confine_service_minted_tokens short-circuits for API controllers
# (is_a?(API::APIController)) before touching auth, so the pipeline's API endpoints are never denied
# by the namespace confinement. The non-API denial is covered deterministically in the HomeController
# spec; the strategy setting Current from a marked token is covered by the jwt_controller D9 guard.
RSpec.describe 'service-minted token confinement (D11) — API namespace', type: :request do
  let(:teacher) { FactoryBot.create(:portal_teacher) }
  let(:oidc_client) do
    Admin::OidcClient.create!(name: 'pipeline', sub: 'sub-1', user: FactoryBot.create(:confirmed_user),
                              can_mint_scoped_tokens: true)
  end

  def marked_token
    claims = {
      :domain => 'http://test.host/',
      :user_type => 'teacher',
      :user_id => "http://test.host/users/#{teacher.user.id}",
      :teacher_id => teacher.id,
      :minted_via_oidc_client_id => oidc_client.id
    }
    SignedJwt.create_portal_token(teacher.user, claims, 3600)
  end

  before(:each) { generate_default_settings_with_mocks }

  it 'does not apply the namespace confinement to API routes' do
    offering = FactoryBot.create(:portal_offering, clazz: teacher.clazzes.first)
    get "/api/v1/offerings/#{offering.id}", headers: { 'Authorization' => "Bearer/JWT #{marked_token}" }
    expect(response.body).not_to match(/service-minted token may only be used on the API/)
  end
end
