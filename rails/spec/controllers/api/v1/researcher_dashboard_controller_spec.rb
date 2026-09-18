require 'spec_helper'

describe API::V1::ResearcherDashboardController, :type => :controller do
  let(:site_url)    { "http://test.host/" }
  let(:status_app)  { "report-service-dev" }
  let(:clue_app)    { "collaborative-learning-staging" }

  let(:cohort)      { FactoryBot.create(:admin_cohort) }
  let(:teacher)     { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)       { FactoryBot.create(:portal_clazz, teachers: [teacher], class_hash: "the-class") }
  let(:other_clazz) { FactoryBot.create(:portal_clazz, teachers: [FactoryBot.create(:portal_teacher)]) }
  let(:project)     { FactoryBot.create(:project, cohorts: [cohort]) }
  let(:client)      { FactoryBot.create(:client) }

  let(:researcher) {
    researcher = FactoryBot.generate(:researcher_user)
    researcher.researcher_for_projects << project
    researcher
  }

  let(:accepted) { { "package" => "class-counts", "doc_path" => "researcher_dashboard/x/classes/the-class/results/class-counts" } }

  def sign_in_as(user)
    grant = user.access_grants.create(client: client, state: nil, access_token_expires_at: Time.now + 1.hour)
    request.headers["Authorization"] = "Bearer #{grant.access_token}"
  end

  def post_run(overrides = {})
    post :run_package, params: {
      class_id: clazz.id,
      package: { name: "class-counts", version: "1.0.0", checksum: "sha256:abc" },
      firebase_project: status_app,
      firebase_apps: [status_app, clue_app]
    }.merge(overrides)
  end

  before(:each) {
    generate_default_settings_with_mocks
    allow(APP_CONFIG).to receive(:[]).and_call_original
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
    sign_in_as(researcher)
  }

  describe "a researcher for the class" do
    it "hands the request to report-service and returns what it says" do
      expect(ResearcherDashboard::RunPackage).to receive(:call) do |args|
        expect(args[:clazz]).to eql clazz
        expect(args[:user]).to eql researcher
        expect(args[:firebase_project]).to eql status_app
        expect(args[:firebase_apps]).to eql [status_app, clue_app]
        expect(args[:package]).to eql({ name: "class-counts", version: "1.0.0", checksum: "sha256:abc" })
        accepted
      end

      post_run
      expect(response.status).to eql 200
      # Exactly what report-service returned, so the runner tokens the portal just minted
      # cannot reach the browser by being folded into this response.
      expect(JSON.parse(response.body)).to eql accepted
    end
  end

  # The only gate on which classes a researcher may analyze, and it runs before anything
  # is minted, so report-service is never asked.
  describe "a researcher without access to the class" do
    it "is refused and nothing is asked of report-service" do
      expect(ResearcherDashboard::RunPackage).not_to receive(:call)
      post_run(class_id: other_clazz.id)
      expect(response.status).to eql 403
    end
  end

  # Otherwise an anonymous caller learns which class ids exist from the difference
  # between the 404 and the 403.
  it "refuses an unauthenticated caller before looking any class up" do
    request.headers["Authorization"] = nil
    expect(Portal::Clazz).not_to receive(:find_by_id)
    expect(ResearcherDashboard::RunPackage).not_to receive(:call)
    post_run
    expect(response.status).to eql 401
  end

  it "reports an unknown class as not found rather than forbidden" do
    expect(ResearcherDashboard::RunPackage).not_to receive(:call)
    post_run(class_id: -1)
    expect(response.status).to eql 404
  end

  describe "a malformed request" do
    before { expect(ResearcherDashboard::RunPackage).not_to receive(:call) }

    it "refuses a package missing its checksum" do
      post_run(package: { name: "class-counts", version: "1.0.0" })
      expect(response.status).to eql 400
    end

    # The package name is the result document's id, so a slash would write a nested
    # collection. Refusing here means a bad name never costs a VM.
    it "refuses a package name that is not a single path segment" do
      post_run(package: { name: "a/b", version: "1.0.0", checksum: "sha256:abc" })
      expect(response.status).to eql 400
    end

    it "refuses a request naming no Firebase apps" do
      post_run(firebase_apps: [])
      expect(response.status).to eql 400
    end

    # Without a class token for its own project the VM cannot write the class or result
    # documents, and refuses only after it has been launched.
    it "refuses when firebase_project is not among the named apps" do
      post_run(firebase_apps: [clue_app])
      expect(response.status).to eql 400
    end
  end
end
