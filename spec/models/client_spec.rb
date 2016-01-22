require 'spec_helper'
require 'delorean'

# Test authentication clients
describe Client do
  let(:domain_machers) { nil }
  let(:client) do
    Client.create(
      app_id: 'testing-client',
      app_secret: 'xyzzy',
      name: 'testing-client',
      site_url: 'http://localhost:8080/',
      domain_matchers: domain_machers
    )
  end
  context "a client that isn't restricted to various domains" do
    it "should validate from any domain" do
      client.should be_valid_from_referer("http://blargonaut.com/")
      client.should be_valid_from_referer("http://foo.com/blarg.html")
    end
  end
  context "a client that has domains matchers set to whitespace" do
    let(:domain_matchers) { "    \t\n   " }
    it "should validate from any domain" do
      client.should be_valid_from_referer("http://blargonaut.com/")
      client.should be_valid_from_referer("http://foo.com/blarg.html")
    end
  end
  context "a client that only works for foo.com or baz.com domains" do
    let(:domain_machers) { "foo.com baz.com" }
    it "should not validate for referers of blargonaut" do
      client.valid_from_referer?("http://blargonaut.com/").should be_false
      client.valid_from_referer?("http://blargonaut.com/foo.com").should be_false
      client.valid_from_referer?("http://blargonaut.com/baz.com").should be_false
    end
    it "should not validate if HTTP_REFERER is missing" do
      client.valid_from_referer?("").should be_false
    end
    it "should validate for referers of foo.com" do
      client.valid_from_referer?("http://foo.com").should be_true
      client.valid_from_referer?("https://foo.com/").should be_true
      client.valid_from_referer?("https://foo.com/index.html").should be_true
    end
    it "should validate for referers of baz.com" do
      client.valid_from_referer?("http://baz.com").should be_true
      client.valid_from_referer?("https://baz.com/").should be_true
      client.valid_from_referer?("https://baz.com/index.html").should be_true
    end
  end
  describe "a client with an access_grant" do
    let(:user)  { FactoryGirl.create(:user) }
    before(:each) do
      user.access_grants.create(client_id: client.id )
      user.reload
      client.reload
    end
    it "should a valid access_grant" do
      client.access_grants.should have(1).grant
      user.access_grants.should have(1).grant
    end

    describe "deting the client" do
      before(:each) do
        client.destroy
        user.reload
      end
      it "should remove the grants from the users" do
        user.access_grants.should have(0).grant
      end
    end
  end
end
