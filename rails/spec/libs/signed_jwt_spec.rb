# frozen_string_literal: false

require 'spec_helper'

RSpec.describe SignedJwt do

  describe "#is_valid_private_key?" do

    it "fails on a invalid private key" do
      expect(SignedJwt::is_valid_private_key?("foo")).to be false
    end

    it "succeeds on a valid private key" do
      valid_private_key = "-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDzAReCWkVgF2eOAMvRRr6i1XOqVO7kcwbczahVR48ZhhmStJaU
P7aZKL9L3bgvQvL9D8T9zFwYjyGiaY5czdob79Z/R+0yReID7Aix7vuFf8e7Hfxk
ltDnCh9jcMTKUMeS4rx8dbAG0XtXkD7ayxv5wfBfaDl5GvtY88eLKgCi9QIDAQAB
AoGBAJP9TjvsjeN/XWl1wqqo0uCH7fEF2Jb4Fm3SMXn+IoAA0wItSKbwRlvwHNAv
L0RZGXJUcDvAgTXTtUAb2L9b/j9lc1/KzZbPFdJDe/A2vqoet8y2Fu955LeS2cPB
0AcCZeTfxtj65wrabapI+gRb6vsHo49FPh4PG3F+NzJZnZrhAkEA/XDgxS/fa0yX
PlUWiGjdDNSclkvbohJcDhQDtAJqbKxeL/xzgobDl4mCylrhsclIPUmXoMjvd8TB
qjqm7f+pdwJBAPV1PGmCqaUwRzY0lXuEBz2fj1RNT7yh5qHT6eZmrFTpb+B/UxXz
gEd86P++bdlXD9CAQFv0ss7sFK90DW71MfMCQCyuU9IvyHHARQHGOny+EAqNCTYu
FYCTQAtzV9vKeTzDfq9zEGI4pA75PUezkgqn88ZqTQMZqa4xz/rU8E0RP60CQQCC
LD5xpj3ZwRTDBngQHSDJ6YjVqHqVCzeIsx3kdqcGERan9F5X0d9CClh26MLQ9H8K
kDmRiuAZJNKDigRlx9tJAkAdrkzo40+vsucH9OxOcR7KkUfufL1EWC4qcqH46oDX
gpZlAvdO9CFaBcBKsAcJnNDQBY2lhFsSeqYs78PoW7Zz
-----END RSA PRIVATE KEY-----"
      expect(SignedJwt::is_valid_private_key?(valid_private_key)).to be true
    end

  end

  describe "#create_firebase_token" do
    let(:firebase_app_name) { FirebaseTestHelper::FIREBASE_TEST_APP_NAME }

    before do
      FirebaseTestHelper.create_test_firebase_app
    end

    it 'backdates iat and keeps token lifetime within expires_in' do
      now = Time.now.to_i
      allow(Time).to receive(:now).and_return(Time.at(now))
      token = SignedJwt.create_firebase_token('test-uid', firebase_app_name, 3600)
      decoded = SignedJwt.decode_firebase_token(token, firebase_app_name)
      payload = decoded[:data]

      expect(payload['iat']).to eq(now - SignedJwt::CLOCK_SKEW_ALLOWANCE)
      expect(payload['exp'] - payload['iat']).to eq(3600)
    end

    it 'respects custom expires_in with backdated iat' do
      now = Time.now.to_i
      allow(Time).to receive(:now).and_return(Time.at(now))
      token = SignedJwt.create_firebase_token('test-uid', firebase_app_name, 1800)
      decoded = SignedJwt.decode_firebase_token(token, firebase_app_name)
      payload = decoded[:data]

      expect(payload['exp'] - payload['iat']).to eq(1800)
    end
  end

  describe "#create_portal_token" do
    let(:user) { FactoryBot.create(:user) }

    it 'includes iss claim set to APP_CONFIG[:site_url]' do
      token = SignedJwt.create_portal_token(user, {}, 3600)
      decoded = JWT.decode(token, nil, false).first
      expect(decoded['iss']).to eq(APP_CONFIG[:site_url])
    end
  end

  describe "#decode_firebase_token_by_iss" do
    let(:firebase_app_name) { FirebaseTestHelper::FIREBASE_TEST_APP_NAME }
    let!(:firebase_app) { FirebaseTestHelper.create_test_firebase_app }

    it 'verifies a good token and returns data, header, and the resolved app' do
      token = SignedJwt.create_firebase_token('uid-1', firebase_app_name, 3600, { foo: 'bar' })
      result = SignedJwt.decode_firebase_token_by_iss(token)
      expect(result[:app]).to eq(firebase_app)
      expect(result[:data]['foo']).to eq('bar')
      expect(result[:data]['iss']).to eq(firebase_app.client_email)
    end

    it 'raises when the signature does not verify' do
      wrong_key = OpenSSL::PKey::RSA.generate(2048)
      payload = { iss: firebase_app.client_email, exp: Time.now.to_i + 3600 }
      token = JWT.encode(payload, wrong_key, 'RS256')
      expect { SignedJwt.decode_firebase_token_by_iss(token) }.to raise_error(SignedJwt::Error, /Signature did not verify/)
    end

    it 'raises when the token is expired' do
      token = SignedJwt.create_firebase_token('uid-1', firebase_app_name, -3600)
      expect { SignedJwt.decode_firebase_token_by_iss(token) }.to raise_error(SignedJwt::Error, /expired/)
    end

    it 'raises for an unknown iss' do
      payload = { iss: 'unknown@nowhere.example.com', exp: Time.now.to_i + 3600 }
      token = JWT.encode(payload, OpenSSL::PKey::RSA.generate(2048), 'RS256')
      expect { SignedJwt.decode_firebase_token_by_iss(token) }.to raise_error(SignedJwt::Error, /No FirebaseApp for iss/)
    end
  end


  describe "RS256 portal tokens" do
    let(:user) { FactoryBot.create(:user) }
    let(:aud)  { SignedJwt::AUD_RESEARCHER_DASHBOARD }
    let(:public_key) { PortalSigningKey.private_key.public_key }
    let(:now) { Time.now.to_i }

    def payload(overrides = {})
      { iss: APP_CONFIG[:site_url], iat: now, exp: now + 600, uid: user.id, aud: aud }.merge(overrides)
    end

    def decode(token, aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)
      SignedJwt.decode_portal_token(token, aud: aud)
    end

    describe "#create_portal_token with aud" do
      it "mints RS256 with the kid header and the standard claims, and no alg claim" do
        token = SignedJwt.create_portal_token(user, {}, 600, aud: aud)
        data, header = JWT.decode(token, nil, false)
        expect(header).to include('alg' => 'RS256', 'kid' => 'test-key')
        expect(data).to include('iss' => APP_CONFIG[:site_url], 'uid' => user.id, 'aud' => aud)
        expect(data['exp'] - data['iat']).to eq(600)
        expect(data).not_to have_key('alg')
      end

      it "refuses an unknown audience" do
        expect { SignedJwt.create_portal_token(user, {}, 600, aud: 'somewhere-else') }
          .to raise_error(SignedJwt::Error, /Unknown portal token audience/)
      end

      it "keeps the legacy HS256 token's shape without aud" do
        token = SignedJwt.create_portal_token(user, {}, 600)
        data, header = JWT.decode(token, nil, false)
        expect(header).to eq('alg' => 'HS256')
        expect(data.keys).to eq(%w[alg iss iat exp uid])
      end

      it "raises SignedJwt::Error when the key is not configured" do
        stub_const('ENV', ENV.to_h.merge('PORTAL_SIGNING_KEY' => ''))
        expect { SignedJwt.create_portal_token(user, {}, 600, aud: aud) }
          .to raise_error(SignedJwt::Error, /PORTAL_SIGNING_KEY/)
      end
    end

    describe "#decode_portal_token" do
      it "accepts the expected audience" do
        token = SignedJwt.create_portal_token(user, { scope_id: 5 }, 600, aud: aud)
        decoded = decode(token)
        expect(decoded[:data]).to include('uid' => user.id, 'scope_id' => 5)
        expect(decoded[:header]['kid']).to eq('test-key')
      end

      it "refuses a wrong audience" do
        token = SignedJwt.create_portal_token(user, {}, 600, aud: SignedJwt::AUD_REPORT_SERVER)
        expect { decode(token) }.to raise_error(SignedJwt::Error)
      end

      it "refuses a missing audience" do
        token = JWT.encode(payload.except(:aud), PortalSigningKey.private_key, 'RS256', { kid: 'test-key' })
        expect { decode(token) }.to raise_error(SignedJwt::Error)
      end

      it "refuses an aud array containing the expected audience" do
        token = JWT.encode(payload(aud: [aud, SignedJwt::AUD_REPORT_SERVER]), PortalSigningKey.private_key, 'RS256', { kid: 'test-key' })
        expect { decode(token) }.to raise_error(SignedJwt::Error, /single string/)
      end

      it "refuses any RS256 token when the call site accepts no audience" do
        SignedJwt::AUDIENCES.each do |a|
          token = SignedJwt.create_portal_token(user, {}, 600, aud: a)
          expect { decode(token, aud: nil) }.to raise_error(SignedJwt::Error, /does not accept RS256/)
        end
      end

      it "still accepts a legacy HS256 token when the call site accepts no audience" do
        token = SignedJwt.create_portal_token(user, {}, 600)
        expect(decode(token, aud: nil)[:data]['uid']).to eq(user.id)
      end

      it "verifies a legacy HS256 token as before at a call site that accepts an audience" do
        token = SignedJwt.create_portal_token(user, {}, 600)
        expect(decode(token)[:data]['uid']).to eq(user.id)
      end

      describe "algorithm confusion" do
        it "refuses an HS256 token carrying the kid, signed with the public key's PEM" do
          token = JWT.encode(payload, public_key.to_pem, 'HS256', { kid: 'test-key' })
          expect { decode(token) }.to raise_error(SignedJwt::Error)
        end

        it "refuses the same token without a kid" do
          token = JWT.encode(payload, public_key.to_pem, 'HS256')
          expect { decode(token) }.to raise_error(SignedJwt::Error)
          expect { decode(token, aud: nil) }.to raise_error(SignedJwt::Error)
        end

        it "refuses alg none with and without a kid" do
          with_kid = JWT.encode(payload, nil, 'none', { kid: 'test-key' })
          without_kid = JWT.encode(payload, nil, 'none')
          expect { decode(with_kid) }.to raise_error(SignedJwt::Error)
          expect { decode(without_kid, aud: nil) }.to raise_error(SignedJwt::Error)
        end
      end

      it "refuses an unknown kid" do
        token = JWT.encode(payload, PortalSigningKey.private_key, 'RS256', { kid: 'other-key' })
        expect { decode(token) }.to raise_error(SignedJwt::Error, /Unrecognized portal signing key id/)
      end

      it "refuses an RS256 token without a kid" do
        token = JWT.encode(payload, PortalSigningKey.private_key, 'RS256')
        expect { decode(token) }.to raise_error(SignedJwt::Error)
      end

      it "refuses a token signed by another environment's key under the same kid" do
        token = JWT.encode(payload, OpenSSL::PKey::RSA.generate(2048), 'RS256', { kid: 'test-key' })
        expect { decode(token) }.to raise_error(SignedJwt::Error)
      end

      it "raises JWT::ExpiredSignature for an expired RS256 token" do
        token = SignedJwt.create_portal_token(user, {}, -600, aud: aud)
        expect { decode(token) }.to raise_error(JWT::ExpiredSignature)
      end

      describe "a token signed by a previous key" do
        let(:previous_key) { OpenSSL::PKey::RSA.generate(2048) }
        let(:token) { JWT.encode(payload, previous_key, 'RS256', { kid: 'previous-key' }) }

        it "verifies when PORTAL_PREVIOUS_VERIFY_KEYS names its kid" do
          stub_const('ENV', ENV.to_h.merge('PORTAL_PREVIOUS_VERIFY_KEYS' => { 'previous-key' => previous_key.public_key.to_pem }.to_json))
          expect(decode(token)[:data]['uid']).to eq(user.id)
        end

        it "is refused otherwise" do
          expect { decode(token) }.to raise_error(SignedJwt::Error, /Unrecognized/)
        end
      end
    end
  end

end
