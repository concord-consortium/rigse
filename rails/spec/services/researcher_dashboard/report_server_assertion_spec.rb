require 'spec_helper'

describe ResearcherDashboard::ReportServerAssertion do
  let(:site_url)   { "http://test.host/" }
  let(:researcher) { FactoryBot.generate(:researcher_user) }
  let(:secret)     { 'shared-secret' }

  before(:each) {
    generate_default_settings_with_mocks
    allow(APP_CONFIG).to receive(:[]).and_call_original
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
    # Captured before stubbing, so the example that removes the secret builds from the
    # real environment rather than from the stub this block just installed.
    @base_env = ENV.to_hash
    stub_const('ENV', @base_env.merge('PORTAL_SERVICE_SECRET' => secret))
  }

  # Decoded with verification on, so an assertion signed with any other key (the portal's
  # own JWT_HMAC_SECRET being the obvious mistake) fails here rather than at report-server.
  def decode(token, key: secret)
    JWT.decode(token, key, true, { algorithm: 'HS256', aud: described_class::AUDIENCE, verify_aud: true }).first
  end

  it "signs the researcher's identity with the secret shared with report-server" do
    claims = decode(described_class.mint(user: researcher))

    expect(claims["portal_user_id"]).to eql researcher.id
    # The host, not the site url: report-server keys its users on the portal host.
    expect(claims["portal_server"]).to eql "test.host"
    expect(claims["login"]).to eql researcher.login
    expect(claims["email"]).to eql researcher.email
    expect(claims["iss"]).to eql "test.host"
  end

  it "is refused by a verifier holding a different secret" do
    token = described_class.mint(user: researcher)
    expect { decode(token, key: 'not-the-shared-secret') }.to raise_error(JWT::VerificationError)
  end

  # The audience is what stops an assertion minted for report-server being replayed at
  # anything else that comes to verify portal claims with the same secret.
  it "names report-server as the audience" do
    claims = decode(described_class.mint(user: researcher))
    expect(claims["aud"]).to eql "report-server"
  end

  # These decide what report-server lets the minted token read. Signing them is the whole
  # point: a relay cannot raise them, where a body-trusting endpoint would let it.
  it "carries the researcher's current role flags rather than fixed ones" do
    project = FactoryBot.create(:project)
    researcher.researcher_for_projects << project

    claims = decode(described_class.mint(user: researcher))
    expect(claims["is_project_researcher"]).to be true
    expect(claims["is_admin"]).to be false
    expect(claims["is_project_admin"]).to be false
  end

  it "distinguishes a site admin, whose token report-server scopes to every project" do
    admin = FactoryBot.generate(:admin_user)
    claims = decode(described_class.mint(user: admin))
    expect(claims["is_admin"]).to be true
  end

  # A long-lived assertion would be a bearer credential in its own right, since anyone
  # holding one can exchange it for that researcher's report-server token.
  it "expires within the declared TTL" do
    now = Time.now.to_i
    claims = decode(described_class.mint(user: researcher))
    expect(claims["exp"]).to be <= now + described_class::TTL
    expect(claims["exp"]).to be > now
  end

  it "gives each assertion its own id, so an exchange can be made single-use later" do
    first  = decode(described_class.mint(user: researcher))
    second = decode(described_class.mint(user: researcher))
    expect(first["jti"]).not_to eql second["jti"]
  end

  # Without this the launch fails inside the function with a claim that was never signed,
  # rather than at the point the portal could not sign one.
  it "raises when the shared secret is not configured" do
    stub_const('ENV', @base_env.tap { |e| e.delete('PORTAL_SERVICE_SECRET') })
    expect { described_class.mint(user: researcher) }
      .to raise_error(described_class::NotConfigured, /PORTAL_SERVICE_SECRET/)
  end
end
