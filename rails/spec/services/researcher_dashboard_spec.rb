require 'spec_helper'

RSpec.describe ResearcherDashboard do
  let(:dashboard_url) { 'https://dashboard.example.com/app/' }
  let(:user)  { FactoryBot.create(:user) }
  let(:clazz) { FactoryBot.create(:portal_clazz) }

  def with_env(overrides)
    stub_const('ENV', ENV.to_h.merge(overrides))
  end

  describe ".enabled?" do
    it "is true with the URL and the signing key configured" do
      with_env('RESEARCHER_DASHBOARD_URL' => dashboard_url)
      expect(ResearcherDashboard.enabled?).to be true
    end

    it "is false without the URL" do
      with_env('RESEARCHER_DASHBOARD_URL' => '')
      expect(ResearcherDashboard.enabled?).to be false
    end

    it "is false without the signing key" do
      with_env('RESEARCHER_DASHBOARD_URL' => dashboard_url, 'PORTAL_SIGNING_KEY' => '')
      expect(ResearcherDashboard.enabled?).to be false
    end
  end

  describe ".launch_url" do
    def launch_params(url)
      Rack::Utils.parse_query(URI.parse(url).query)
    end

    it "adds token as the only parameter to a URL that has none" do
      with_env('RESEARCHER_DASHBOARD_URL' => dashboard_url)
      url = ResearcherDashboard.launch_url(user: user, clazz: clazz)
      expect(url).to start_with("#{dashboard_url}?token=")
      expect(launch_params(url).keys).to eq(['token'])
    end

    it "keeps the configured URL's own parameters" do
      with_env('RESEARCHER_DASHBOARD_URL' => "#{dashboard_url}?env=staging")
      expect(launch_params(ResearcherDashboard.launch_url(user: user, clazz: clazz)).keys).to eq(%w[env token])
    end

    it "carries a two-hour class-scoped launch token with no role flags" do
      with_env('RESEARCHER_DASHBOARD_URL' => dashboard_url)
      token = launch_params(ResearcherDashboard.launch_url(user: user, clazz: clazz))['token']
      decoded = SignedJwt.decode_portal_token(token, aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)
      data = decoded[:data]

      expect(decoded[:header]['kid']).to eq('test-key')
      expect(data).to include(
        'iss' => APP_CONFIG[:site_url],
        'uid' => user.id,
        'aud' => SignedJwt::AUD_RESEARCHER_DASHBOARD,
        'user_type' => 'researcher',
        'scope_kind' => 'class',
        'scope_id' => clazz.id
      )
      expect(data['scope_id']).to be_an(Integer)
      expect(data['exp'] - data['iat']).to eq(2.hours.to_i)
      expect(data.keys).not_to include('is_admin', 'is_project_admin', 'is_project_researcher', 'admin', 'project_admins')
    end
  end
end
