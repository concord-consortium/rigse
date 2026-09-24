require 'spec_helper'

RSpec.describe ResearcherDashboard::Assertions do
  let(:user)  { FactoryBot.create(:confirmed_user, first_name: 'Ada', last_name: 'Lovelace') }
  let(:clazz) { FactoryBot.create(:portal_clazz) }
  let(:other_audiences) { ->(aud) { SignedJwt::AUDIENCES - [aud] } }

  def decode(token, aud)
    SignedJwt.decode_portal_token(token, aud: aud)[:data]
  end

  describe ".report_server" do
    let(:aud)   { SignedJwt::AUD_REPORT_SERVER }
    let(:token) { described_class.report_server(user: user, clazz: clazz) }

    it "verifies only under its own audience" do
      expect(decode(token, aud)['aud']).to eq(aud)
      other_audiences.(aud).each do |other|
        expect { decode(token, other) }.to raise_error(SignedJwt::Error)
      end
    end

    it "carries the scope, report-server's user fields and a two-minute life" do
      data = decode(token, aud)
      expect(data).to include(
        'iss' => APP_CONFIG[:site_url],
        'uid' => user.id,
        'user_type' => 'researcher',
        'scope_kind' => 'class',
        'scope_id' => clazz.id,
        'portal_user_id' => user.id,
        'portal_server' => URI.parse(APP_CONFIG[:site_url]).host,
        'login' => user.login,
        'first_name' => 'Ada',
        'last_name' => 'Lovelace',
        'email' => user.email
      )
      expect(data['exp'] - data['iat']).to eq(120)
    end

    it "carries a UUID jti that differs per call" do
      first = decode(token, aud)['jti']
      second = decode(described_class.report_server(user: user, clazz: clazz), aud)['jti']
      expect(first).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(second).not_to eq(first)
    end

    describe "role flags" do
      let(:project) { FactoryBot.create(:project) }

      def flags(for_user)
        decode(described_class.report_server(user: for_user, clazz: clazz), aud)
          .slice('is_admin', 'is_project_admin', 'is_project_researcher')
      end

      it "are all false for a plain user" do
        expect(flags(user)).to eq('is_admin' => false, 'is_project_admin' => false, 'is_project_researcher' => false)
      end

      it "mark a site admin" do
        expect(flags(FactoryBot.generate(:admin_user))['is_admin']).to be true
      end

      it "mark a project admin" do
        user.add_role_for_project('admin', project)
        expect(flags(user)['is_project_admin']).to be true
      end

      it "mark a project researcher" do
        user.add_role_for_project('researcher', project)
        expect(flags(user)['is_project_researcher']).to be true
      end

      it "do not mark a researcher whose grant has expired" do
        user.add_role_for_project('researcher', project, expiration_date: Time.now - 1.day)
        expect(flags(user)['is_project_researcher']).to be false
      end
    end
  end

  describe ".report_service_functions" do
    let(:aud)   { SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS }
    let(:token) { described_class.report_service_functions(user: user) }

    it "verifies only under its own audience" do
      expect(decode(token, aud)['aud']).to eq(aud)
      other_audiences.(aud).each do |other|
        expect { decode(token, other) }.to raise_error(SignedJwt::Error)
      end
    end

    it "carries exactly iss, iat, exp, uid and aud, and a two-minute life" do
      data = decode(token, aud)
      expect(data.keys).to match_array(%w[iss iat exp uid aud])
      expect(data['uid']).to eq(user.id)
      expect(data['exp'] - data['iat']).to eq(120)
    end
  end
end
