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

  # Revocation is what makes the eight-hour VM lifetime real for this credential, since
  # the token itself carries no expiry.
  it "revokes the researcher's dashboard tokens through report-server" do
    expect(HTTParty).to receive(:delete) do |url, options|
      expect(url).to eql endpoint
      # A signed claim, not the secret: report-server names the researcher from the
      # verified assertion, so the secret never travels and no body is needed.
      presented = options[:headers]["Authorization"].sub("Bearer ", "")
      claims = JWT.decode(presented, 'shared-secret', true,
                          { algorithm: 'HS256', aud: 'report-server', verify_aud: true }).first
      expect(claims["portal_user_id"]).to eql researcher.id
      # The host, not the site url: report-server keys its users on the portal host.
      expect(claims["portal_server"]).to eql "test.host"
      expect(options[:body]).to be_nil
      double(success?: true, code: 200, parsed_response: { "revoked" => 1 })
    end

    expect(described_class.revoke(user: researcher)["revoked"]).to eql 1
  end

  it "raises rather than reporting success when report-server refuses" do
    allow(HTTParty).to receive(:delete).and_return(
      double(success?: false, code: 401, parsed_response: {})
    )
    expect { described_class.revoke(user: researcher) }
      .to raise_error(described_class::Error, /401/)
  end

  # The assertion cannot be signed without it, so the refusal comes from the minter.
  it "raises when the signing secret is not configured" do
    stub_const('ENV', @base_env.merge('REPORT_SERVER_URL' => 'https://report-server.example.org')
      .tap { |e| e.delete('PORTAL_SERVICE_SECRET') })
    expect { described_class.revoke(user: researcher) }
      .to raise_error(ResearcherDashboard::ReportServerAssertion::NotConfigured, /PORTAL_SERVICE_SECRET/)
  end

  it "raises when the report-server url is not configured" do
    stub_const('ENV', @base_env.merge('PORTAL_SERVICE_SECRET' => 'shared-secret')
      .tap { |e| e.delete('REPORT_SERVER_URL') })
    expect { described_class.revoke(user: researcher) }
      .to raise_error(described_class::NotConfigured, /REPORT_SERVER_URL/)
  end
end
