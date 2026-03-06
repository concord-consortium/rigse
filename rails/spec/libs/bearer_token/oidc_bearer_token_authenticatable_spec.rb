require 'spec_helper'
require 'google_oidc_verifier'

describe OidcBearerTokenAuthenticatable::BearerToken do
  let(:strategy) { OidcBearerTokenAuthenticatable::BearerToken.new(nil) }
  let(:request)  { double('request') }
  let(:mapping)  { Devise.mappings[:user] }
  let(:user)     { FactoryBot.create(:user) }
  let(:params)   { {} }

  before(:each) do
    allow(strategy).to receive(:mapping).and_return(mapping)
    allow(strategy).to receive(:request).and_return(request)
    allow(request).to receive(:params).and_return(params)
    allow(request).to receive(:env).and_return({})
    allow(request).to receive(:request_method).and_return('POST')
    allow(request).to receive(:path).and_return('/api/v1/test')
  end

  describe '#valid?' do
    it 'returns false when no Authorization header' do
      allow(request).to receive(:headers).and_return({})
      expect(strategy.valid?).to be false
    end

    it 'returns false for Bearer with opaque token (no dots)' do
      allow(request).to receive(:headers).and_return({'Authorization' => 'Bearer abc123hex'})
      expect(strategy.valid?).to be false
    end

    it 'returns false for Bearer/JWT scheme' do
      allow(request).to receive(:headers).and_return({'Authorization' => 'Bearer/JWT some.jwt.token'})
      expect(strategy.valid?).to be false
    end

    it 'returns true for Bearer with Google OIDC token (iss is accounts.google.com)' do
      payload = { iss: 'https://accounts.google.com', sub: '12345', exp: Time.now.to_i + 600 }
      token = JWT.encode(payload, 'key', 'HS256')
      allow(request).to receive(:headers).and_return({'Authorization' => "Bearer #{token}"})
      expect(strategy.valid?).to be true
    end

    it 'returns false for Bearer with non-Google JWT (different iss)' do
      payload = { iss: APP_CONFIG[:site_url], uid: 1, exp: Time.now.to_i + 600 }
      token = JWT.encode(payload, 'key', 'HS256')
      allow(request).to receive(:headers).and_return({'Authorization' => "Bearer #{token}"})
      expect(strategy.valid?).to be false
    end

    it 'returns false for Bearer with JWT that has no iss' do
      payload = { uid: 1, exp: Time.now.to_i + 600 }
      token = JWT.encode(payload, 'key', 'HS256')
      allow(request).to receive(:headers).and_return({'Authorization' => "Bearer #{token}"})
      expect(strategy.valid?).to be false
    end
  end

  describe '#authenticate!' do
    let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:oidc_sub) { 'google-sa-sub-12345' }
    let(:oidc_email) { 'test-sa@project.iam.gserviceaccount.com' }
    let(:decoded_payload) do
      {
        'iss' => 'https://accounts.google.com',
        'sub' => oidc_sub,
        'email' => oidc_email,
        'aud' => 'http://localhost:3000',
        'exp' => Time.now.to_i + 3600,
        'iat' => Time.now.to_i
      }
    end
    let(:token) { JWT.encode(decoded_payload, rsa_key, 'RS256', { kid: 'test-kid' }) }

    before(:each) do
      allow(request).to receive(:headers).and_return({'Authorization' => "Bearer #{token}"})
    end

    context 'with valid OIDC token and matching active OidcClient' do
      let!(:oidc_client) do
        Admin::OidcClient.create!(name: 'Test SA', sub: oidc_sub, email: oidc_email, user: user, active: true)
      end

      before do
        allow(GoogleOidcVerifier).to receive(:verify).with(token).and_return(decoded_payload)
      end

      it 'authenticates and returns success' do
        expect(strategy.authenticate!).to eql :success
      end

      it 'sets portal.auth_strategy env' do
        strategy.authenticate!
        expect(request.env['portal.auth_strategy']).to eq('oidc_bearer_token')
      end

      it 'sets portal.auth_client env' do
        strategy.authenticate!
        expect(request.env['portal.auth_client']).to eq('Test SA')
      end
    end

    context 'with valid OIDC token but no matching OidcClient' do
      before do
        allow(GoogleOidcVerifier).to receive(:verify).with(token).and_return(decoded_payload)
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end

      it 'logs a warning with sub and email' do
        expect(Rails.logger).to receive(:warn).with(/OidcBearer:.*sub=#{oidc_sub}.*email=#{oidc_email}/)
        strategy.authenticate!
      end
    end

    context 'with valid OIDC token but inactive OidcClient' do
      let!(:oidc_client) do
        Admin::OidcClient.create!(name: 'Disabled SA', sub: oidc_sub, email: oidc_email, user: user, active: false)
      end

      before do
        allow(GoogleOidcVerifier).to receive(:verify).with(token).and_return(decoded_payload)
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end

      it 'logs a warning about inactive client' do
        expect(Rails.logger).to receive(:warn).with(/OidcBearer:.*inactive.*Disabled SA/)
        strategy.authenticate!
      end
    end

    context 'when GoogleOidcVerifier raises an error' do
      before do
        allow(GoogleOidcVerifier).to receive(:verify).and_raise(GoogleOidcVerifier::Error, 'Signature has expired')
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end

      it 'logs the verification failure' do
        expect(Rails.logger).to receive(:warn).with(/OidcBearer:.*Signature has expired/)
        strategy.authenticate!
      end
    end

    context 'when token issuer is not Google (non-OIDC JWT)' do
      before do
        allow(GoogleOidcVerifier).to receive(:verify).and_raise(GoogleOidcVerifier::Error, 'Invalid issuer')
      end

      it 'fails authentication' do
        expect(strategy.authenticate!).to eql :failure
      end
    end
  end
end
