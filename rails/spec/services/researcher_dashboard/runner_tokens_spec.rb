require 'spec_helper'

RSpec.describe ResearcherDashboard::RunnerTokens do
  let(:user)  { FactoryBot.create(:user) }
  let(:clazz) { FactoryBot.create(:portal_clazz) }
  let(:app_name) { 'report-service-dev' }

  let!(:firebase_app) { FirebaseTestHelper.create_test_firebase_app(name: app_name) }

  def decode(token)
    SignedJwt.decode_firebase_token(token, app_name)[:data]
  end

  describe ".session_token" do
    let(:data) { decode(described_class.session_token(user: user, firebase_app: app_name)) }

    it "carries the identity claims and the runner claim, and no class" do
      expect(data['uid']).to eq(FirebaseTokenClaims.uid(user))
      expect(data['claims']).to eq(
        FirebaseTokenClaims.identity(user).stringify_keys.merge('user_type' => 'researcher', 'researcher_dashboard_runner' => true)
      )
      expect(data['claims']).not_to have_key('class_hash')
    end

    it "lives the hour a Firebase custom token allows" do
      expect(data['exp'] - data['iat']).to eq(3600)
    end
  end

  describe ".class_token" do
    let(:data) { decode(described_class.class_token(user: user, clazz: clazz, firebase_app: app_name)) }

    it "adds the class hash to the session token's claims" do
      expect(data['uid']).to eq(FirebaseTokenClaims.uid(user))
      expect(data['claims']).to include('user_type' => 'researcher', 'researcher_dashboard_runner' => true, 'class_hash' => clazz.class_hash)
      expect(data['claims']).to include(FirebaseTokenClaims.identity(user).stringify_keys)
      expect(data['exp'] - data['iat']).to eq(3600)
    end
  end

  it "raises for an unknown FirebaseApp" do
    expect { described_class.session_token(user: user, firebase_app: 'nope') }.to raise_error(SignedJwt::Error)
    expect { described_class.class_token(user: user, clazz: clazz, firebase_app: 'nope') }.to raise_error(SignedJwt::Error)
  end
end
