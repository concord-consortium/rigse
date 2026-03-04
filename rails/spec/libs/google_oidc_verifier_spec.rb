require 'spec_helper'
require 'google_oidc_verifier'

describe GoogleOidcVerifier do
  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:kid) { 'test-key-id-1' }
  let(:audience) { 'http://localhost:3000' }
  let(:issuer) { 'https://accounts.google.com' }
  let(:now) { Time.now.to_i }

  let(:valid_payload) do
    {
      'iss' => issuer,
      'aud' => audience,
      'sub' => '123456789',
      'email' => 'test@test.iam.gserviceaccount.com',
      'iat' => now,
      'exp' => now + 3600
    }
  end

  let(:jwks_response) do
    jwk = JWT::JWK.new(rsa_key, kid: kid)
    { 'keys' => [jwk.export] }.to_json
  end

  def sign_token(payload, key: rsa_key, key_id: kid)
    JWT.encode(payload, key, 'RS256', { kid: key_id })
  end

  before(:each) do
    # Reset cached keys between tests
    GoogleOidcVerifier.instance_variable_set(:@jwks_keys, nil)
    GoogleOidcVerifier.instance_variable_set(:@jwks_fetched_at, nil)

    # Stub APP_CONFIG
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(audience)

    # Stub Net::HTTP to return our test JWKS
    stub_request(:get, GoogleOidcVerifier::JWKS_URI)
      .to_return(status: 200, body: jwks_response, headers: { 'Content-Type' => 'application/json' })
  end

  describe '.verify' do
    it 'returns decoded payload for a valid token' do
      token = sign_token(valid_payload)
      result = GoogleOidcVerifier.verify(token)
      expect(result['sub']).to eq('123456789')
      expect(result['email']).to eq('test@test.iam.gserviceaccount.com')
    end

    it 'raises error for expired token' do
      payload = valid_payload.merge('exp' => now - 60)
      token = sign_token(payload)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error, /Signature has expired/)
    end

    it 'raises error for wrong audience' do
      payload = valid_payload.merge('aud' => 'https://wrong-site.example.com')
      token = sign_token(payload)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error, /Invalid audience/)
    end

    it 'raises error for wrong issuer' do
      payload = valid_payload.merge('iss' => 'https://evil.example.com')
      token = sign_token(payload)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error, /Invalid issuer/)
    end

    it 'raises error for invalid signature' do
      other_key = OpenSSL::PKey::RSA.generate(2048)
      token = sign_token(valid_payload, key: other_key)
      expect { GoogleOidcVerifier.verify(token) }
        .to raise_error(GoogleOidcVerifier::Error)
    end

    context 'JWKS key rotation' do
      it 'refreshes keys once when kid is not found, then fails' do
        unknown_kid_token = sign_token(valid_payload, key_id: 'unknown-kid')
        expect { GoogleOidcVerifier.verify(unknown_kid_token) }
          .to raise_error(GoogleOidcVerifier::Error, /Could not find public key/)
        # Should have fetched JWKS twice (initial + one refresh)
        expect(WebMock).to have_requested(:get, GoogleOidcVerifier::JWKS_URI).twice
      end
    end

    context 'JWKS fetch failure' do
      it 'uses stale cached keys when fetch fails' do
        # Prime the cache with a successful fetch
        token1 = sign_token(valid_payload)
        GoogleOidcVerifier.verify(token1)

        # Expire the cache
        GoogleOidcVerifier.instance_variable_set(:@jwks_fetched_at, Time.now - 7200)

        # Make fetch fail
        stub_request(:get, GoogleOidcVerifier::JWKS_URI)
          .to_return(status: 500, body: 'Internal Server Error')

        # Should still work with stale cache
        token2 = sign_token(valid_payload.merge('exp' => Time.now.to_i + 3600))
        result = GoogleOidcVerifier.verify(token2)
        expect(result['sub']).to eq('123456789')
      end

      it 'raises error when fetch fails with no cache' do
        stub_request(:get, GoogleOidcVerifier::JWKS_URI)
          .to_return(status: 500, body: 'Internal Server Error')

        token = sign_token(valid_payload)
        expect { GoogleOidcVerifier.verify(token) }
          .to raise_error(GoogleOidcVerifier::Error, /fetch.*JWKS/i)
      end
    end

    context 'issuer variants' do
      it 'accepts accounts.google.com without https prefix' do
        payload = valid_payload.merge('iss' => 'accounts.google.com')
        token = sign_token(payload)
        result = GoogleOidcVerifier.verify(token)
        expect(result['sub']).to eq('123456789')
      end
    end
  end
end
