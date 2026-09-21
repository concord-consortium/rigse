require 'spec_helper'

describe ResearcherDashboard::RunPackage do
  let(:site_url)      { "http://learn.portal.staging.concord.org/" }
  let(:status_app)    { FirebaseTestHelper::FIREBASE_TEST_APP_NAME }
  let(:clue_app)      { "collaborative-learning-staging" }
  let(:endpoint)      { "https://report-service.example.org/api/run_package" }

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

  let(:package) { { name: "class-counts", version: "1.0.0", checksum: "sha256:abc" } }

  before(:each) {
    generate_default_settings_with_mocks
    allow(APP_CONFIG).to receive(:[]).and_call_original
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
    FirebaseTestHelper.create_test_firebase_app
    FirebaseTestHelper.create_test_firebase_app(name: clue_app)
    @base_env = ENV.to_hash
    stub_const('ENV', @base_env.merge(
      'REPORT_SERVICE_URL' => 'https://report-service.example.org/api',
      'REPORT_SERVICE_BEARER_TOKEN' => 'report-service-bearer',
      'PORTAL_SERVICE_SECRET' => 'shared-secret'
    ))
  }

  def run(user: researcher, klass: clazz, apps: [status_app, clue_app], project_app: status_app)
    described_class.call(user: user, clazz: klass, package: package,
                         firebase_project: project_app, firebase_apps: apps)
  end

  def posted
    body = nil
    allow(HTTParty).to receive(:post) do |_url, options|
      body = JSON.parse(options[:body])
      double(success?: true, code: 202, parsed_response: { "doc_path" => "p" })
    end
    yield
    body
  end

  def claims_in(token, app:)
    SignedJwt.decode_firebase_token(token, app)[:data]["claims"]
  end

  it "posts to report-service with the bearer the portal already holds" do
    expect(HTTParty).to receive(:post) do |url, options|
      expect(url).to eql endpoint
      expect(options[:headers]["Authorization"]).to eql "Bearer report-service-bearer"
      double(success?: true, code: 202, parsed_response: { "doc_path" => "results/class-counts" })
    end

    expect(run["doc_path"]).to eql "results/class-counts"
  end

  # One per Firebase project the run signs into: a custom token is signed by one project's
  # service account and cannot be exchanged in another.
  it "mints a class token per named app, keyed by app name" do
    body = posted { run }

    expect(body["class_tokens"].keys).to match_array [status_app, clue_app]
    expect(claims_in(body["class_tokens"][status_app], app: status_app)["class_hash"]).to eql "the-class"
    expect(claims_in(body["class_tokens"][clue_app], app: clue_app)["class_hash"]).to eql "the-class"
  end

  it "mints only the apps that were named" do
    body = posted { run(apps: [status_app]) }
    expect(body["class_tokens"].keys).to eql [status_app]
  end

  # The status document lives only in report-service's own project, and the session token
  # names no class because it is not scoped to one.
  it "mints the session token for the named firebase_project, without a class" do
    body = posted { run }

    claims = claims_in(body["session_token"], app: status_app)
    expect(claims["researcher_dashboard_runner"]).to be true
    expect(claims).not_to have_key "class_hash"
    expect(body["firebase_project"]).to eql status_app
  end

  it "carries the identity and portal segment the VM is told to use" do
    body = posted { run }

    expect(body["scope"]).to eql({ "kind" => "class", "class_hash" => "the-class", "class_id" => clazz.id })
    expect(body["package"]).to eql({ "name" => "class-counts", "version" => "1.0.0", "checksum" => "sha256:abc" })
    expect(body["platform_user_id"]).to eql researcher.id
    expect(body["platform_id"]).to eql site_url
    # Dots become underscores, which is how CLUE and report-service already key
    # portal-scoped collections.
    expect(body["portal"]).to eql "learn_portal_staging_concord_org"
  end

  it "carries the assertion report-service exchanges for the researcher's own token" do
    body = posted { run }

    claims = JWT.decode(body["report_server_assertion"], 'shared-secret', true,
                        { algorithm: 'HS256', aud: 'report-server', verify_aud: true }).first
    expect(claims["portal_user_id"]).to eql researcher.id
  end

  # The refusal is the portal's and report-service never hears about it, so a class the
  # researcher may not analyze cannot have anything written for it.
  it "refuses a class the researcher cannot analyze without calling report-service" do
    expect(HTTParty).not_to receive(:post)
    expect { run(klass: other_clazz) }
      .to raise_error(ResearcherDashboard::RunnerToken::NotAuthorized)
  end

  it "raises rather than reporting success when report-service refuses" do
    allow(HTTParty).to receive(:post).and_return(double(success?: false, code: 500, parsed_response: {}))
    expect { run }.to raise_error(described_class::Refused, /500/)
  end

  # The caller decides what a refusal means to the researcher, and it cannot do that from
  # the message: a busy VM is a wait, and everything else is a failure.
  it "carries the upstream status on the refusal" do
    allow(HTTParty).to receive(:post).and_return(double(success?: false, code: 409, parsed_response: {}))
    expect { run }.to raise_error(described_class::Refused) { |e| expect(e.status).to eql 409 }
  end

  # Without this a launch failure is invisible from outside report-service: every cause
  # reads as 502, and finding out why needs the function's own log and a live gcloud
  # session. report-service already puts the reason in the body.
  it "carries report-service's reason, not just its status" do
    allow(HTTParty).to receive(:post).and_return(
      double(success?: false, code: 502, parsed_response: { "error" => "no AWS credentials configured" })
    )
    expect { run }.to raise_error(described_class::Refused, /no AWS credentials configured/)
  end

  it "still refuses cleanly when the body says nothing" do
    allow(HTTParty).to receive(:post).and_return(double(success?: false, code: 502, parsed_response: nil))
    expect { run }.to raise_error(described_class::Refused, /502/)
  end

  it "raises when report-service is not configured" do
    stub_const('ENV', @base_env.merge('REPORT_SERVICE_BEARER_TOKEN' => 'x')
      .tap { |e| e.delete('REPORT_SERVICE_URL') })
    expect { run }.to raise_error(described_class::NotConfigured, /REPORT_SERVICE_URL/)
  end

  it "raises when the report-service bearer is not configured" do
    stub_const('ENV', @base_env.merge('REPORT_SERVICE_URL' => 'https://report-service.example.org/api')
      .tap { |e| e.delete('REPORT_SERVICE_BEARER_TOKEN') })
    expect { run }.to raise_error(described_class::NotConfigured, /REPORT_SERVICE_BEARER_TOKEN/)
  end
end
