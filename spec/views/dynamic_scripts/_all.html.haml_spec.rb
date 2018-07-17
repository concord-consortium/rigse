require 'spec_helper'

describe "dynamic_scripts/_all.html.haml" do
  before(:each) do
    view.stub(:current_user).and_return(nil)
    ENV.stub(:[]).and_return('')
  end

  context "when ENEWS_API_KEY is not set" do
    it "sets Portal.enewsSubscriptionEnabled to false" do
      render partial: 'dynamic_scripts/all'
      expect(rendered).to match 'Portal.enewsSubscriptionEnabled = false'
    end
  end

  context "when ENEWS_API_KEY is set" do
    it "sets Portal.enewsSubscriptionEnabled to false" do
      ENV.stub(:[]).with("ENEWS_API_KEY").and_return('12345')
      render partial: 'dynamic_scripts/all'
      expect(rendered).to match 'Portal.enewsSubscriptionEnabled = true'
    end
  end
end
