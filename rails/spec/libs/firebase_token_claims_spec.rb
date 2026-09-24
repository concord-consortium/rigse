require 'spec_helper'
require 'digest/md5'

RSpec.describe FirebaseTokenClaims do
  let(:user) { FactoryBot.create(:user) }
  let(:site_url) { 'https://portal.example' }
  let(:user_url) { "https://portal.example/users/#{user.id}" }

  before(:each) do
    allow(APP_CONFIG).to receive(:[]).and_call_original
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
  end

  it "names the user by the site URL and the user's path" do
    expect(described_class.user_id(user)).to eq(user_url)
  end

  context "with a trailing slash on the site URL" do
    let(:site_url) { 'https://portal.example/' }

    it "drops it" do
      expect(described_class.user_id(user)).to eq(user_url)
    end
  end

  it "uses the MD5 of the user id as the uid" do
    expect(described_class.uid(user)).to eq(Digest::MD5.hexdigest(user_url))
  end

  it "carries the platform, the portal user id and the user id" do
    expect(described_class.identity(user)).to eq(platform_id: site_url, platform_user_id: user.id, user_id: user_url)
  end
end
