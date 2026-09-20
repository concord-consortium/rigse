require 'spec_helper'

describe ResearcherDashboard::Launch do
  let(:dashboard_url) { "https://researcher-dashboard.concord.org/index.html" }
  let(:teacher)       { FactoryBot.create(:portal_teacher) }
  let(:clazz)         { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
  let(:researcher)    { FactoryBot.generate(:researcher_user) }
  let!(:client)       { FactoryBot.create(:client, app_id: described_class::CLIENT_APP_ID, name: 'Researcher Dashboard') }

  def launch
    described_class.url_for(clazz: clazz, user: researcher, protocol: "https://", host: "portal.test")
  end

  def query_of(url)
    Rack::Utils.parse_query(URI.parse(url).query)
  end

  before { allow(ENV).to receive(:[]).and_call_original }

  describe "with a dashboard configured" do
    before { allow(ENV).to receive(:[]).with('RESEARCHER_DASHBOARD_URL').and_return(dashboard_url) }

    it "sends the researcher to the configured dashboard" do
      expect(launch).to start_with("https://researcher-dashboard.concord.org/index.html?")
    end

    it "names the page, since the app switches on it rather than on a path" do
      expect(query_of(launch)["page"]).to eq("analyze-class")
    end

    it "carries the api url of the class, not its id" do
      expect(query_of(launch)["class"]).to eq("https://portal.test/api/v1/classes/#{clazz.id}")
    end

    it "carries a grant for this user against the dashboard client" do
      token = query_of(launch)["token"]
      grant = AccessGrant.find_by(access_token: token)
      expect(grant.user).to eq(researcher)
      expect(grant.client).to eq(client)
    end

    it "carries a grant that expires, because the launch url will be bookmarked" do
      grant = AccessGrant.find_by(access_token: query_of(launch)["token"])
      expect(grant.access_token_expires_at).to be_within(1.minute)
        .of(Time.now + ExternalReport::ReportTokenValidFor)
    end

    it "says the researcher is a researcher, which is a different view of the class" do
      expect(query_of(launch)["researcher"]).to eq("true")
    end

    # No runner token is ever in a browser's hands: the design rests on that, and this is
    # the one url a browser is handed.
    it "carries no runner token of either shape" do
      expect(query_of(launch).keys).to match_array(%w[page class token researcher])
    end

    describe "when the configured url already has query parameters" do
      let(:dashboard_url) { "https://dashboard.test/index.html?version=3" }

      it "keeps them" do
        expect(query_of(launch)["version"]).to eq("3")
        expect(query_of(launch)["page"]).to eq("analyze-class")
      end
    end

    describe "and no Client record has been created" do
      before { client.update!(app_id: "something-else") }

      # The Client is made through the admin UI, so a deployment can have the url and not
      # the record. Failing here is better than launching a researcher at a page whose
      # every portal call will be refused.
      it "refuses rather than launching with a grant it cannot make" do
        expect { launch }.to raise_error(described_class::NotConfigured, /researcher-dashboard/)
      end
    end
  end

  describe "with no dashboard configured" do
    before { allow(ENV).to receive(:[]).with('RESEARCHER_DASHBOARD_URL').and_return(nil) }

    it "refuses" do
      expect { launch }.to raise_error(described_class::NotConfigured, /RESEARCHER_DASHBOARD_URL/)
    end
  end
end
