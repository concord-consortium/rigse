require 'spec_helper'

describe ForwardedFirebaseToken do
  let(:app_name) { 'report-service-dev' }
  let!(:firebase_app) { FirebaseTestHelper.create_test_firebase_app(name: app_name) }

  let(:student) { FactoryBot.create(:full_portal_student) }
  let(:clazz)   { FactoryBot.create(:portal_clazz, students: [student]) }
  let(:offering) { FactoryBot.create(:portal_offering, clazz: clazz) }

  def mint(claims_overrides: {}, app: app_name, expires_in: 3600)
    claims = {
      platform_id: APP_CONFIG[:site_url],
      platform_user_id: student.user.id,
      user_type: 'learner',
      class_hash: offering.clazz.class_hash,
      offering_id: offering.id
    }.merge(claims_overrides)
    SignedJwt.create_firebase_token(student.user.id, app, expires_in, { claims: claims })
  end

  describe '.verify happy path' do
    it 'returns the user, origin offering, and origin clazz' do
      result = ForwardedFirebaseToken.verify(mint)
      expect(result.user).to eq(student.user)
      expect(result.origin_offering).to eq(offering)
      expect(result.origin_clazz).to eq(clazz)
    end
  end

  describe '.verify failure modes' do
    it 'rejects a token from a non-allowlisted app' do
      FirebaseApp.create!(
        name: 'not-allowed',
        client_email: 'not-allowed@example.com',
        private_key: FirebaseTestHelper::FIREBASE_TEST_PRIVATE_KEY
      )
      token = mint(app: 'not-allowed')
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:app_not_allowed) }
    end

    it 'rejects a platform_id mismatch' do
      token = mint(claims_overrides: { platform_id: 'http://evil.example.com' })
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:platform_id) }
    end

    it 'rejects a non-learner token' do
      token = mint(claims_overrides: { user_type: 'teacher' })
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:not_learner) }
    end

    it 'rejects a user that cannot be resolved to a portal student' do
      non_student = FactoryBot.create(:user)
      token = mint(claims_overrides: { platform_user_id: non_student.id })
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:user_unresolved) }
    end

    it 'rejects a missing offering' do
      token = mint(claims_overrides: { offering_id: -1 })
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:offering_unresolved) }
    end

    it 'rejects a class_hash mismatch' do
      token = mint(claims_overrides: { class_hash: 'not-the-real-hash' })
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:class_hash_mismatch) }
    end

    it 'rejects an expired token' do
      token = mint(expires_in: -3600)
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:expired) }
    end

    it 'reports :app_not_found when the iss matches no FirebaseApp' do
      claims = { iss: 'orphan@example.com', sub: 'orphan@example.com', exp: Time.now.to_i + 3600, claims: {} }
      token = JWT.encode(claims, OpenSSL::PKey::RSA.generate(2048), 'RS256')
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:app_not_found) }
    end

    it 'reports :no_iss when the token has no iss claim' do
      token = JWT.encode({ exp: Time.now.to_i + 3600, claims: {} }, OpenSSL::PKey::RSA.generate(2048), 'RS256')
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:no_iss) }
    end

    it 'reports :undecodable for a token that cannot be parsed' do
      expect { ForwardedFirebaseToken.verify('not-a-jwt') }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:undecodable) }
    end

    it 'rejects a token signed with a different key' do
      wrong_key = OpenSSL::PKey::RSA.generate(2048)
      claims = {
        iss: firebase_app.client_email,
        sub: firebase_app.client_email,
        exp: Time.now.to_i + 3600,
        claims: {
          platform_id: APP_CONFIG[:site_url],
          platform_user_id: student.user.id,
          user_type: 'learner',
          class_hash: offering.clazz.class_hash,
          offering_id: offering.id
        }
      }
      token = JWT.encode(claims, wrong_key, 'RS256')
      expect { ForwardedFirebaseToken.verify(token) }.to raise_error(ForwardedFirebaseToken::Invalid) { |e| expect(e.reason).to eq(:signature) }
    end
  end

  describe '.allowed_app_names' do
    it 'falls back to the defaults when config is absent' do
      allow(APP_CONFIG).to receive(:[]).and_call_original
      allow(APP_CONFIG).to receive(:[]).with(:forwarded_firebase_app_names).and_return(nil)
      expect(ForwardedFirebaseToken.allowed_app_names).to eq(ForwardedFirebaseToken::DEFAULT_APP_NAMES)
    end
  end
end
