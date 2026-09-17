require 'spec_helper'
require 'digest/md5'

describe ResearcherDashboard::RunnerToken do
  let(:site_url)      { "http://test.host/" }
  let(:firebase_app)  { FirebaseTestHelper::FIREBASE_TEST_APP_NAME }

  let(:cohort)        { FactoryBot.create(:admin_cohort) }
  let(:teacher)       { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)         { FactoryBot.create(:portal_clazz, teachers: [teacher], class_hash: "the-class") }
  let(:other_clazz)   { FactoryBot.create(:portal_clazz, teachers: [FactoryBot.create(:portal_teacher)], class_hash: "another-class") }
  let(:project)       { FactoryBot.create(:project, cohorts: [cohort]) }

  let(:researcher) {
    researcher = FactoryBot.generate(:researcher_user)
    researcher.researcher_for_projects << project
    researcher
  }

  before(:each) {
    generate_default_settings_with_mocks
    allow(APP_CONFIG).to receive(:[]).and_call_original
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
    FirebaseTestHelper.create_test_firebase_app
  }

  def claims_in(token, app: firebase_app)
    SignedJwt.decode_firebase_token(token, app)[:data]["claims"]
  end

  def payload_of(token, app: firebase_app)
    SignedJwt.decode_firebase_token(token, app)[:data]
  end

  describe ".session_token" do
    subject(:token) {
      described_class.session_token(user: researcher, class_hash: clazz.class_hash, firebase_app: firebase_app)
    }

    it "carries the researcher identity and the runner claim" do
      expect(claims_in(token)).to include(
        "platform_id" => site_url,
        "platform_user_id" => researcher.id,
        "user_id" => "http://test.host/users/#{researcher.id}",
        "user_type" => "researcher",
        "researcher_dashboard_runner" => true
      )
    end

    it "does not carry a class_hash, so it cannot read a class" do
      expect(claims_in(token)).not_to have_key("class_hash")
    end
  end

  describe ".class_token" do
    subject(:token) {
      described_class.class_token(user: researcher, class_hash: clazz.class_hash, firebase_app: firebase_app)
    }

    it "carries the session token's claims plus the class_hash the rules key on" do
      expect(claims_in(token)).to include(
        "platform_id" => site_url,
        "platform_user_id" => researcher.id,
        "user_id" => "http://test.host/users/#{researcher.id}",
        "user_type" => "researcher",
        "researcher_dashboard_runner" => true,
        "class_hash" => clazz.class_hash
      )
    end
  end

  # A runner token that signed in as a different Firebase user than the browser does for
  # the same researcher would read and write a different principal's documents.
  it "mints the same Firebase uid the browser endpoint mints for that researcher" do
    token = described_class.session_token(user: researcher, class_hash: clazz.class_hash, firebase_app: firebase_app)

    expect(payload_of(token)["uid"]).to eql Digest::MD5.hexdigest("http://test.host/users/#{researcher.id}")
  end

  it "expires after RunnerToken::TTL" do
    token = described_class.session_token(user: researcher, class_hash: clazz.class_hash, firebase_app: firebase_app)
    payload = payload_of(token)

    expect(payload["exp"] - payload["iat"]).to eql described_class::TTL
  end

  # One custom token serves one Firebase project, so an analysis that reads CLUE and
  # writes report-service needs a mint per project.
  it "signs with the named FirebaseApp rather than a fixed one" do
    other_app = FirebaseApp.create!(
      name: "collaborative-learning-staging",
      client_email: "clue@example.com",
      private_key: FirebaseTestHelper::FIREBASE_TEST_PRIVATE_KEY
    )

    report_service_token = described_class.class_token(
      user: researcher, class_hash: clazz.class_hash, firebase_app: firebase_app
    )
    clue_token = described_class.class_token(
      user: researcher, class_hash: clazz.class_hash, firebase_app: other_app.name
    )

    expect(payload_of(report_service_token)["iss"]).to eql "user@example.com"
    expect(payload_of(clue_token, app: other_app.name)["iss"]).to eql "clue@example.com"
  end

  it "raises on an unknown FirebaseApp name" do
    expect {
      described_class.session_token(user: researcher, class_hash: clazz.class_hash, firebase_app: "no such app")
    }.to raise_error(SignedJwt::Error, /Unknown firebase app name/)
  end

  describe "authorization" do
    shared_examples "mints both shapes" do
      it "mints a session token" do
        expect(
          described_class.session_token(user: user, class_hash: clazz.class_hash, firebase_app: firebase_app)
        ).to be_present
      end

      it "mints a class token" do
        expect(
          described_class.class_token(user: user, class_hash: clazz.class_hash, firebase_app: firebase_app)
        ).to be_present
      end
    end

    shared_examples "mints neither shape" do
      it "refuses a session token" do
        expect {
          described_class.session_token(user: user, class_hash: clazz.class_hash, firebase_app: firebase_app)
        }.to raise_error(ResearcherDashboard::RunnerToken::NotAuthorized)
      end

      it "refuses a class token" do
        expect {
          described_class.class_token(user: user, class_hash: clazz.class_hash, firebase_app: firebase_app)
        }.to raise_error(ResearcherDashboard::RunnerToken::NotAuthorized)
      end
    end

    context "a project researcher for the class" do
      let(:user) { researcher }
      include_examples "mints both shapes"
    end

    context "a project admin for the class" do
      let(:user) {
        project_admin = FactoryBot.generate(:author_user)
        project_admin.admin_for_projects << project
        project_admin
      }
      include_examples "mints both shapes"
    end

    context "a site admin" do
      let(:user) { FactoryBot.generate(:admin_user) }
      include_examples "mints both shapes"
    end

    context "a user with no researcher standing at all" do
      let(:user) { FactoryBot.create(:user) }
      include_examples "mints neither shape"
    end

    context "a researcher whose projects do not reach the class" do
      let(:user) {
        researcher = FactoryBot.generate(:researcher_user)
        researcher.researcher_for_projects << FactoryBot.create(:project, cohorts: [])
        researcher
      }
      include_examples "mints neither shape"
    end

    # The session token names no class but is authorized by one, so a researcher who can
    # reach no class gets no token of either shape.
    it "refuses a session token for a class the researcher cannot reach, even though the shape carries no class" do
      expect {
        described_class.session_token(
          user: researcher, class_hash: other_clazz.class_hash, firebase_app: firebase_app
        )
      }.to raise_error(ResearcherDashboard::RunnerToken::NotAuthorized)
    end

    it "refuses a class_hash that matches no class" do
      expect {
        described_class.class_token(user: researcher, class_hash: "not-a-class", firebase_app: firebase_app)
      }.to raise_error(ResearcherDashboard::RunnerToken::ClassNotFound)
    end

    it "refuses a blank class_hash" do
      expect {
        described_class.session_token(user: researcher, class_hash: "", firebase_app: firebase_app)
      }.to raise_error(ResearcherDashboard::RunnerToken::ClassNotFound)
    end
  end
end
