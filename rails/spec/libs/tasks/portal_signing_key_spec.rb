require 'spec_helper'
require 'rake'

describe 'portal_signing_key:public' do
  before do
    Rake.application.rake_require 'tasks/portal_signing_key'
    Rake::Task.define_task(:environment)
  end

  after(:each) do
    Rake::Task['portal_signing_key:public'].reenable
  end

  let(:entry) do
    original = $stdout
    begin
      $stdout = StringIO.new
      Rake.application.invoke_task 'portal_signing_key:public'
      JSON.parse($stdout.string.lines.last)
    ensure
      $stdout = original
    end
  end

  it 'prints the kid and public key report-server and the function are configured with' do
    expect(entry['kid']).to eq PortalSigningKey.kid
    expect(entry['pem']).to eq PortalSigningKey.private_key.public_key.to_pem
  end

  # Both verifiers trust a key only for its own issuer and compare the claim as a string, so
  # an entry whose iss differs from the signed claim by a trailing slash verifies nothing.
  # The site URL here carries one, since stripping it is the mutation worth catching.
  context 'when the site URL ends in a slash' do
    let(:site_url) { 'https://learn.example.org/' }
    let(:user)     { FactoryBot.create(:confirmed_user) }

    before do
      allow(APP_CONFIG).to receive(:[]).and_call_original
      allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
    end

    it 'prints iss exactly as a signed token carries it' do
      token = SignedJwt.create_assertion(user, aud: 'report-server', expires_in: 60)
      claims, _header = JWT.decode(token, PortalSigningKey.private_key.public_key, true, algorithm: 'RS256')
      expect(entry['iss']).to eq claims['iss']
      expect(entry['iss']).to eq site_url
    end
  end
end
