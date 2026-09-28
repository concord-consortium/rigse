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


  describe "RS256 tokens" do
    let(:user) { FactoryBot.create(:user) }
    let(:key)  { PortalSigningKey.private_key }
    let(:now)  { Time.now.to_i }
    let(:site) { APP_CONFIG[:site_url] }

    def access_token(claims = {}, header = {})
      JWT.encode({ iss: site, aud: [site], uid: user.id, exp: now + 60, scope: 'class:researcher-read' }.merge(claims),
                 key, 'RS256', { kid: PortalSigningKey.kid, typ: 'at+jwt' }.merge(header))
    end

    it "accepts rigse's own access token, whose aud lists rigse among others" do
      data = SignedJwt.decode_portal_token(access_token(aud: [site, 'https://report-server.example.org']))[:data]
      expect(data['uid']).to eq(user.id)
    end

    it "refuses an access token whose aud does not name rigse" do
      expect { SignedJwt.decode_portal_token(access_token(aud: ['https://elsewhere.example.org'])) }.to raise_error(SignedJwt::Error)
    end

    it "refuses an RS256 token that is not an access token, which is every assertion" do
      expect { SignedJwt.decode_portal_token(access_token({}, typ: 'JWT')) }.to raise_error(SignedJwt::Error)
      assertion = SignedJwt.create_assertion(user, aud: SignedJwt::AUD_REPORT_SERVER, expires_in: 60)
      expect { SignedJwt.decode_portal_token(assertion) }.to raise_error(SignedJwt::Error)
    end

    it "refuses an HS256 token signed with the public key as its secret" do
      forged = JWT.encode({ iss: site, aud: [site], uid: user.id, exp: now + 60 }, key.public_key.to_pem, 'HS256',
                          { kid: PortalSigningKey.kid, typ: 'at+jwt' })
      expect { SignedJwt.decode_portal_token(forged) }.to raise_error(SignedJwt::Error)
    end

    it "accepts a token signed by the previous key during a rotation" do
      old = OpenSSL::PKey::RSA.generate(2048)
      stub_const('ENV', ENV.to_h.merge('PORTAL_PREVIOUS_VERIFY_KEYS' => { 'old-key' => old.public_key.to_pem }.to_json))
      token = JWT.encode({ iss: site, aud: [site], uid: user.id, exp: now + 60 }, old, 'RS256', { kid: 'old-key', typ: 'at+jwt' })
      expect(SignedJwt.decode_portal_token(token)[:data]['uid']).to eq(user.id)
    end

    it "refuses an RS256 token with no kid, which routes to the HS256 check" do
      token = JWT.encode({ iss: site, aud: [site], uid: user.id, exp: now + 60 }, key, 'RS256', { typ: 'at+jwt' })
      expect { SignedJwt.decode_portal_token(token) }.to raise_error(SignedJwt::Error)
    end

    it "refuses an unknown kid rather than falling back to a default key" do
      expect { SignedJwt.decode_portal_token(access_token({}, kid: 'nope')) }.to raise_error(SignedJwt::Error, /Unrecognized/)
    end

    it "refuses a token signed by another environment's key under the same kid" do
      other = OpenSSL::PKey::RSA.generate(2048)
      token = JWT.encode({ iss: site, aud: [site], uid: user.id, exp: now + 60 }, other, 'RS256', { kid: PortalSigningKey.kid, typ: 'at+jwt' })
      expect { SignedJwt.decode_portal_token(token) }.to raise_error(SignedJwt::Error)
    end

    it "still accepts a legacy HS256 portal token" do
      expect(SignedJwt.decode_portal_token(SignedJwt.create_portal_token(user))[:data]['uid']).to eq(user.id)
    end

    it "signs each assertion with exactly one audience" do
      [SignedJwt::AUD_REPORT_SERVER, SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS].each do |aud|
        data, header = JWT.decode(SignedJwt.create_assertion(user, aud: aud, expires_in: 60), key.public_key, true, algorithm: 'RS256', aud: aud, verify_aud: true)
        expect(data['aud']).to eq(aud)
        expect(header['kid']).to eq(PortalSigningKey.kid)
      end
      expect { SignedJwt.create_assertion(user, aud: 'researcher-dashboard', expires_in: 60) }.to raise_error(SignedJwt::Error)
    end

    it "issues an access token that decode_portal_token accepts" do
      token = SignedJwt.create_access_token(user, client_id: 'c', capabilities: ['class:researcher-read'], context: nil,
                                            audiences: [site], expires_in: 60)
      data, header = SignedJwt.decode_portal_token(token).values_at(:data, :header)
      expect(header).to include('typ' => 'at+jwt', 'kid' => PortalSigningKey.kid, 'alg' => 'RS256')
      expect(data).to include('iss' => site, 'sub' => user.id.to_s, 'uid' => user.id, 'aud' => [site],
                              'client_id' => 'c', 'scope' => 'class:researcher-read')
      expect(data).not_to have_key('context')
      expect(data['jti']).to be_present
    end

    it "carries the context when there is one, and a new jti each time" do
      mint = -> { SignedJwt.create_access_token(user, client_id: 'c', capabilities: ['class:researcher-read'],
                                                context: { type: 'class', id: 7 }, audiences: [site], expires_in: 60) }
      first, second = [mint.call, mint.call].map { |t| JWT.decode(t, nil, false).first }
      expect(first['context']).to eq('type' => 'class', 'id' => 7)
      expect(first['jti']).not_to eq(second['jti'])
    end

    it "refuses an access token aud that does not start with this portal or names an assertion audience" do
      [[SignedJwt::AUD_REPORT_SERVER], [site, SignedJwt::AUD_REPORT_SERVER], [site, SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS],
       ['https://other.example.org', site]].each do |audiences|
        expect { SignedJwt.create_access_token(user, client_id: 'c', capabilities: [], context: nil, audiences: audiences, expires_in: 60) }
          .to raise_error(SignedJwt::Error)
      end
    end

    # The jwt gem accepts any aud list containing the expected value, so an assertion's aud
    # must always be a single string.
    it "never signs an assertion with an aud list" do
      [SignedJwt::AUD_REPORT_SERVER, SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS].each do |aud|
        data = JWT.decode(SignedJwt.create_assertion(user, aud: aud, expires_in: 60), nil, false).first
        expect(data['aud']).to be_a(String)
      end
      expect { SignedJwt.create_assertion(user, aud: [SignedJwt::AUD_REPORT_SERVER], expires_in: 60) }.to raise_error(SignedJwt::Error)
      expect { SignedJwt.create_assertion(user, aud: SignedJwt::AUD_REPORT_SERVER, expires_in: 60, claims: { aud: ['x'] }) }.to raise_error(/Duplicate JWT claim key: aud/)
    end

    it "never lets an access token's aud list name an assertion audience" do
      TokenCapabilities.names.each do |name|
        expect(SignedJwt::ASSERTION_AUDIENCES).not_to include(TokenCapabilities.audience_value(name))
      end
      token = SignedJwt.create_access_token(user, client_id: 'c', capabilities: TokenCapabilities.names, context: nil,
                                            audiences: [site, 'https://report-server.example.org'], expires_in: 60)
      data = JWT.decode(token, nil, false).first
      expect(data['aud']).to be_an(Array)
      expect(data['aud'] & SignedJwt::ASSERTION_AUDIENCES).to be_empty
    end
  end

  describe "#create_portal_token under a scoped request" do
    after(:each) { Current.reset }

    it "inherits the request's scope and context" do
      user = FactoryBot.create(:user)
      TokenScope.apply!('scope' => 'portal-api', 'context' => { 'type' => 'class', 'id' => 7 })
      data = SignedJwt.decode_portal_token(SignedJwt.create_portal_token(user))[:data]
      expect(data).to include('scope' => 'portal-api', 'context' => { 'type' => 'class', 'id' => 7 })
    end
  end
end
