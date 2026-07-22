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

  describe '#store?' do
    it 'returns false' do
      expect(strategy.store?).to be false
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
    let(:forwarded_token) { 'forwarded.jwt.value' }
    let(:headers) { {'Authorization' => "Bearer #{token}"} }
    let(:student) { FactoryBot.create(:full_portal_student) }
    let(:clazz)   { FactoryBot.create(:portal_clazz, students: [student]) }
    let(:origin_offering) { FactoryBot.create(:portal_offering, clazz: clazz) }
    let(:forwarded_result) do
      ForwardedFirebaseToken::Result.new(user: student.user, origin_offering: origin_offering, origin_clazz: clazz)
    end

    before(:each) do
      allow(request).to receive(:headers).and_return(headers)
      allow(GoogleOidcVerifier).to receive(:verify).with(token).and_return(decoded_payload)
    end

    context 'non-opted-in client (no capabilities, no requires_forwarded_jwt)' do
      let!(:oidc_client) do
        Admin::OidcClient.create!(name: 'Test SA', sub: oidc_sub, email: oidc_email, user: user, active: true)
      end

      it 'authenticates as the mapped user and stamps common env' do
        expect(strategy.authenticate!).to eql :success
        expect(strategy.user).to eq(user)
        expect(request.env['portal.auth_strategy']).to eq('oidc_bearer_token')
        expect(request.env['portal.auth_client']).to eq('Test SA')
        expect(request.env['portal.auth_client_id']).to eq(oidc_client.id)
        details = request.env['portal.auth_details']
        expect(details[:sub]).to eq(oidc_sub)
        expect(details[:email]).to eq(oidc_email)
        expect(details[:aud]).to eq('http://localhost:3000')
      end

      it 'ignores a forwarded header and never acts as the forwarded student' do
        headers['X-Portal-Student-JWT'] = forwarded_token
        expect(ForwardedFirebaseToken).not_to receive(:verify)
        expect(strategy.authenticate!).to eql :success
        expect(strategy.user).to eq(user)
        expect(request.env['portal.forwarded_student']).to be_nil
      end
    end

    context 'opted-in client (has capabilities), requires_forwarded_jwt false' do
      let!(:oidc_client) do
        Admin::OidcClient.create!(name: 'Test SA', sub: oidc_sub, email: oidc_email, user: user,
                                  active: true, capabilities: ['update_offering_state'])
      end

      context 'with no forwarded header' do
        it 'falls back to the mapped user without setting skip_trackable' do
          expect(strategy.authenticate!).to eql :success
          expect(strategy.user).to eq(user)
          expect(request.env['portal.auth_client_id']).to eq(oidc_client.id)
          expect(request.env['portal.forwarded_student']).to be_nil
          expect(request.env['devise.skip_trackable']).to be_nil
        end

        it 'logs the header-absent fallback' do
          expect(Rails.logger).to receive(:info).with(/header-absent fallback to mapped user client=#{oidc_client.id}/)
          strategy.authenticate!
        end
      end

      context 'with a valid forwarded learner token' do
        before do
          headers['X-Portal-Student-JWT'] = forwarded_token
          allow(ForwardedFirebaseToken).to receive(:verify).with(forwarded_token).and_return(forwarded_result)
        end

        it 'authenticates as the forwarded student and stamps the origin + skip_trackable' do
          expect(strategy.authenticate!).to eql :success
          expect(strategy.user).to eq(student.user)
          expect(request.env['portal.forwarded_student']).to be true
          expect(request.env['portal.origin_offering_id']).to eq(origin_offering.id)
          expect(request.env['portal.origin_class_hash']).to eq(clazz.class_hash)
          expect(request.env['portal.auth_client_id']).to eq(oidc_client.id)
          expect(request.env['devise.skip_trackable']).to be true
        end
      end

      context 'with an invalid forwarded token' do
        before do
          headers['X-Portal-Student-JWT'] = forwarded_token
          allow(ForwardedFirebaseToken).to receive(:verify).with(forwarded_token)
            .and_raise(ForwardedFirebaseToken::Invalid.new(:class_hash_mismatch))
        end

        it 'fails with forwarded_token_invalid and never falls back to the mapped user' do
          expect(strategy.authenticate!).to eql :failure
          expect(request.env['portal.auth_error']).to eq('forwarded_token_invalid')
          expect(request.env['portal.forwarded_student']).to be_nil
        end
      end
    end

    context 'client requires forwarded JWT with header absent' do
      shared_examples 'requires the forwarded token' do
        it 'fails with forwarded_token_required and never authenticates a nil user' do
          expect(strategy.authenticate!).to eql :failure
          expect(request.env['portal.auth_error']).to eq('forwarded_token_required')
          expect(request.env['portal.forwarded_student']).to be_nil
        end
      end

      context 'with capabilities and a mapped user' do
        let!(:oidc_client) do
          Admin::OidcClient.create!(name: 'Test SA', sub: oidc_sub, email: oidc_email, user: user,
                                    active: true, requires_forwarded_jwt: true, capabilities: ['update_offering_state'])
        end
        include_examples 'requires the forwarded token'
      end

      context 'Phase-2 state: empty capabilities and null user' do
        let!(:oidc_client) do
          Admin::OidcClient.create!(name: 'Test SA', sub: oidc_sub, email: oidc_email,
                                    active: true, requires_forwarded_jwt: true)
        end
        include_examples 'requires the forwarded token'
      end
    end

    context 'OIDC failures' do
      it 'fails with oidc_token_invalid when no client matches' do
        expect(strategy.authenticate!).to eql :failure
        expect(request.env['portal.auth_error']).to eq('oidc_token_invalid')
      end

      it 'logs a warning with sub and email when no client matches' do
        allow(Rails.logger).to receive(:warn)
        strategy.authenticate!
        expect(Rails.logger).to have_received(:warn).with(/OidcBearer:.*sub=#{oidc_sub}.*email=#{oidc_email}/)
      end

      context 'inactive client' do
        let!(:oidc_client) do
          Admin::OidcClient.create!(name: 'Disabled SA', sub: oidc_sub, email: oidc_email, user: user, active: false)
        end

        it 'fails with oidc_token_invalid' do
          expect(strategy.authenticate!).to eql :failure
          expect(request.env['portal.auth_error']).to eq('oidc_token_invalid')
        end
      end

      context 'when GoogleOidcVerifier raises' do
        before do
          allow(GoogleOidcVerifier).to receive(:verify).and_raise(GoogleOidcVerifier::Error, 'Signature has expired')
        end

        it 'fails with oidc_token_invalid' do
          expect(strategy.authenticate!).to eql :failure
          expect(request.env['portal.auth_error']).to eq('oidc_token_invalid')
        end

        it 'logs the sanitized verification failure' do
          expect(Rails.logger).to receive(:warn).with(/OidcBearer:.*Signature has expired/)
          strategy.authenticate!
        end
      end
    end
  end
end
