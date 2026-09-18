require 'spec_helper'

describe ResearcherDashboard::ReportServerToken do
  let(:site_url)   { "http://test.host/" }
  let(:researcher) { FactoryBot.generate(:researcher_user) }
  let(:endpoint)   { "https://report-server.example.org/api/v1/dashboard-tokens" }

  before(:each) {
    generate_default_settings_with_mocks
    allow(APP_CONFIG).to receive(:[]).and_call_original
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
    # Captured before stubbing, so an example that removes one variable builds from the
    # real environment rather than from the stub the outer block just installed.
    @base_env = ENV.to_hash
    stub_const('ENV', @base_env.merge(
      'REPORT_SERVER_URL' => 'https://report-server.example.org',
      'PORTAL_SERVICE_SECRET' => 'shared-secret'
    ))
  }

  def stub_report_server(method: :post, code: 201, body: { "token" => "ccd_abc" })
    response = double(success?: code < 400, code: code, parsed_response: body)
    allow(HTTParty).to receive(method).and_return(response)
    response
  end

  it "asks report-server to mint a token for the researcher" do
    stub_report_server
    expect(HTTParty).to receive(:post) do |url, options|
      expect(url).to eql endpoint
      expect(options[:headers]["Authorization"]).to eql "Bearer shared-secret"
      body = JSON.parse(options[:body])
      expect(body["portal_user_id"]).to eql researcher.id
      # The host, not the site url: report-server keys its users on the portal host.
      expect(body["portal_server"]).to eql "test.host"
      double(success?: true, code: 201, parsed_response: { "token" => "ccd_abc" })
    end

    expect(described_class.mint(user: researcher)["token"]).to eql "ccd_abc"
  end

  # These decide what report-server lets the token read, and the portal is the authority
  # on them; report-server's own copy is only as fresh as the user's last sign-in there.
  it "sends the researcher's current role flags" do
    project = FactoryBot.create(:project)
    researcher.researcher_for_projects << project

    expect(HTTParty).to receive(:post) do |_url, options|
      body = JSON.parse(options[:body])
      expect(body["is_project_researcher"]).to be true
      expect(body["is_admin"]).to be false
      double(success?: true, code: 201, parsed_response: {})
    end

    described_class.mint(user: researcher)
  end

  it "revokes through the same endpoint, which is what makes a token die with its VM" do
    expect(HTTParty).to receive(:delete).and_return(
      double(success?: true, code: 200, parsed_response: { "revoked" => 1 })
    )
    expect(described_class.revoke(user: researcher)["revoked"]).to eql 1
  end

  it "raises rather than returning nothing when report-server refuses" do
    stub_report_server(code: 401, body: {})
    expect { described_class.mint(user: researcher) }
      .to raise_error(described_class::Error, /401/)
  end

  # Without this the launch would fail deep in the VM with a credential that was never
  # sent, rather than at the point the portal could not ask for one.
  it "raises when the shared secret is not configured" do
    stub_const('ENV', @base_env.merge('REPORT_SERVER_URL' => 'https://report-server.example.org')
      .tap { |e| e.delete('PORTAL_SERVICE_SECRET') })
    expect { described_class.mint(user: researcher) }
      .to raise_error(described_class::NotConfigured, /PORTAL_SERVICE_SECRET/)
  end

  it "raises when the report-server url is not configured" do
    stub_const('ENV', @base_env.merge('PORTAL_SERVICE_SECRET' => 'shared-secret')
      .tap { |e| e.delete('REPORT_SERVER_URL') })
    expect { described_class.mint(user: researcher) }
      .to raise_error(described_class::NotConfigured, /REPORT_SERVER_URL/)
  end
end
