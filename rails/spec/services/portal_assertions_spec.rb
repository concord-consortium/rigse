require 'spec_helper'

RSpec.describe PortalAssertions do
  let(:user)  { FactoryBot.create(:confirmed_user) }
  let(:clazz) { FactoryBot.create(:portal_clazz) }
  let(:key)   { PortalSigningKey.private_key.public_key }

  def decode(token, aud)
    JWT.decode(token, key, true, algorithm: 'RS256', aud: aud, verify_aud: true)
  end

  it 'signs the report-server assertion with the fields its user row needs and a jti' do
    data, header = decode(PortalAssertions.report_server(user: user, clazz: clazz), 'report-server')
    expect(header['kid']).to eq(PortalSigningKey.kid)
    expect(data).to include('iss' => APP_CONFIG[:site_url], 'uid' => user.id, 'portal_user_id' => user.id, 'user_type' => 'researcher',
                            'login' => user.login, 'email' => user.email, 'context' => { 'type' => 'class', 'id' => clazz.id },
                            'is_admin' => false, 'is_project_admin' => false, 'is_project_researcher' => false)
    expect(data['jti']).to be_present
    expect(data['exp'] - data['iat']).to eq(PortalAssertions::TTL)
  end

  it 'signs the function assertion with only who it is for' do
    data, = decode(PortalAssertions.report_service_functions(user: user), 'report-service-functions')
    expect(data.keys).to match_array(%w[iss aud iat exp uid])
  end
end
