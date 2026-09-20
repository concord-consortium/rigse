require 'spec_helper'

# The launch action behind the Analyze link on the Research Classes table. Kept apart from
# clazzes_controller_spec because everything here turns on the researcher check rather than
# on the teaching policy the rest of that controller uses.
describe Portal::ClazzesController, :type => :controller do
  let(:dashboard_url) { "https://dash.test/index.html" }
  let(:cohort)        { FactoryBot.create(:admin_cohort) }
  let(:teacher)       { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)         { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
  let(:project)       { FactoryBot.create(:project, cohorts: [cohort]) }
  let!(:client)       { FactoryBot.create(:client, name: ResearcherDashboard::Launch::CLIENT_NAME) }

  let(:researcher) do
    user = FactoryBot.generate(:researcher_user)
    user.researcher_for_projects << project
    user
  end

  let(:other_researcher) do
    user = FactoryBot.generate(:researcher_user)
    user.researcher_for_projects << FactoryBot.create(:project)
    user
  end

  before(:each) do
    generate_default_settings_with_mocks
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('RESEARCHER_DASHBOARD_URL').and_return(dashboard_url)
  end

  describe "as a researcher for the class" do
    before { sign_in researcher }

    it "redirects to the dashboard" do
      get :researcher_dashboard, params: { id: clazz.id }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to start_with("https://dash.test/index.html?")
    end

    it "carries a grant for this researcher" do
      get :researcher_dashboard, params: { id: clazz.id }
      token = Rack::Utils.parse_query(URI.parse(response.location).query)["token"]
      expect(AccessGrant.find_by(access_token: token).user).to eq(researcher)
    end
  end

  # The negative case criterion 15 exercises. A researcher of some other project has no
  # business analyzing this class, and the link is not rendered for them either, so this is
  # the second line rather than the only one.
  describe "as a researcher for a different project" do
    before { sign_in other_researcher }

    # ApplicationController rescues Pundit::NotAuthorizedError into the portal's standard
    # refusal, so what a browser sees is the alert and a redirect home rather than an error
    # page. Asserting that rather than the exception is asserting what actually happens.
    it "refuses, sending them home rather than to the dashboard" do
      get :researcher_dashboard, params: { id: clazz.id }
      expect(response.location).not_to include("dash.test")
      expect(flash['alert']).to be_present
    end
  end

  describe "when the deployment has no dashboard" do
    before do
      allow(ENV).to receive(:[]).with('RESEARCHER_DASHBOARD_URL').and_return(nil)
      sign_in researcher
    end

    # The link is gated on the same condition, so reaching this means a stale tab or a
    # bookmark. Failing is better than redirecting to nowhere.
    it "refuses rather than redirecting to an empty url" do
      expect {
        get :researcher_dashboard, params: { id: clazz.id }
      }.to raise_error(ResearcherDashboard::Launch::NotConfigured)
    end
  end
end
