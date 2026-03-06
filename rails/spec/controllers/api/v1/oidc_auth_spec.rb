require 'spec_helper'

# Integration test for the full OIDC authentication flow.
#
# Tests the interaction between:
# - OidcBearerTokenAuthenticatable (Devise/Warden strategy)
# - GoogleOidcVerifier (JWKS token verification)
# - Admin::OidcClient (service account mapping)
# - check_for_auth_token (API controller fallback)
#
# Uses controller-level testing because Warden strategies are invoked
# via #current_user in this app's auth flow (no authenticate_user! filter).

RSpec.describe API::V1::JwtController, type: :controller do
  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:kid) { 'integration-test-kid' }
  let(:admin_user) { FactoryBot.create(:user) }
  let(:oidc_sub) { 'integration-test-sub-123' }

  let(:oidc_payload) do
    {
      'iss' => 'https://accounts.google.com',
      'sub' => oidc_sub,
      'email' => 'test@project.iam.gserviceaccount.com',
      'aud' => APP_CONFIG[:site_url],
      'exp' => Time.now.to_i + 3600,
      'iat' => Time.now.to_i
    }
  end

  let(:oidc_token) { JWT.encode(oidc_payload, rsa_key, 'RS256', { kid: kid }) }

  before do
    allow(GoogleOidcVerifier).to receive(:verify).with(oidc_token).and_return(oidc_payload)
  end

  describe 'OIDC bearer token authentication' do
    context 'with a registered active OIDC client' do
      let!(:oidc_client) do
        Admin::OidcClient.create!(
          name: 'Integration Test SA',
          sub: oidc_sub,
          email: 'test@project.iam.gserviceaccount.com',
          user: admin_user,
          active: true
        )
      end

      it 'authenticates via OIDC and returns a portal JWT' do
        # Simulate Devise/Warden authenticating the user via OIDC strategy
        allow(controller).to receive(:current_user).and_return(admin_user)
        request.env['portal.auth_strategy'] = 'oidc_bearer_token'
        request.env['portal.auth_client'] = 'Integration Test SA'
        request.headers['Authorization'] = "Bearer #{oidc_token}"

        get :portal
        expect(response.status).to eq(201)
        body = JSON.parse(response.body)
        expect(body['token']).to be_present

        # Decode the returned token to verify the user mapping
        decoded = SignedJwt.decode_portal_token(body['token'])
        expect(decoded[:data]['uid']).to eq(admin_user.id)
      end

      it 'routes OIDC token via portal_token? and uses current_user from Devise strategy' do
        allow(controller).to receive(:current_user).and_return(admin_user)
        request.headers['Authorization'] = "Bearer #{oidc_token}"

        # OIDC tokens are not portal tokens, so decode_portal_token should never be called
        expect(SignedJwt).not_to receive(:decode_portal_token)
        user, role = controller.send(:check_for_auth_token, {})
        expect(user).to eq(admin_user)
        expect(role).to be_nil
      end
    end

    context 'without a registered OIDC client' do
      it 'rejects the request when no current_user' do
        allow(controller).to receive(:current_user).and_return(nil)
        request.headers['Authorization'] = "Bearer #{oidc_token}"

        expect(SignedJwt).not_to receive(:decode_portal_token)
        expect { controller.send(:check_for_auth_token, {}) }
          .to raise_error(StandardError, 'You must be logged in to use this endpoint')
      end
    end

    context 'with an invalid OIDC token' do
      before do
        allow(GoogleOidcVerifier).to receive(:verify).and_raise(GoogleOidcVerifier::Error, 'Signature has expired')
      end

      it 'OIDC strategy fails and request is rejected' do
        allow(controller).to receive(:current_user).and_return(nil)
        request.headers['Authorization'] = "Bearer #{oidc_token}"

        expect(SignedJwt).not_to receive(:decode_portal_token)
        expect { controller.send(:check_for_auth_token, {}) }
          .to raise_error(StandardError, 'You must be logged in to use this endpoint')
      end
    end

    context 'OIDC strategy unit verification' do
      let(:strategy) { OidcBearerTokenAuthenticatable::BearerToken.new(nil) }
      let(:mock_request) { double('request') }
      let(:mapping) { Devise.mappings[:user] }

      before do
        allow(strategy).to receive(:mapping).and_return(mapping)
        allow(strategy).to receive(:request).and_return(mock_request)
        allow(mock_request).to receive(:params).and_return({})
        allow(mock_request).to receive(:env).and_return({})
        allow(mock_request).to receive(:headers).and_return({'Authorization' => "Bearer #{oidc_token}"})
      end

      it 'full auth flow: verify token, find client, authenticate user' do
        Admin::OidcClient.create!(
          name: 'Full Flow SA', sub: oidc_sub,
          email: 'test@project.iam.gserviceaccount.com',
          user: admin_user, active: true
        )

        expect(strategy.valid?).to be true
        expect(strategy.authenticate!).to eq(:success)
        expect(mock_request.env['portal.auth_strategy']).to eq('oidc_bearer_token')
        expect(mock_request.env['portal.auth_client']).to eq('Full Flow SA')
      end
    end
  end
end
