require 'spec_helper'

describe "dynamic_scripts/_all.html.haml" do
  before(:each) do
    allow(view).to receive(:current_user).and_return(nil)
    allow(ENV).to receive(:[]).and_return('')
  end

  context "when ENEWS_API_KEY is not set" do
    it "sets Portal.enewsSubscriptionEnabled to false" do
      render partial: 'dynamic_scripts/all'
      expect(rendered).to match 'Portal.enewsSubscriptionEnabled = false'
    end
  end

  context "when ENEWS_API_KEY is set" do
    it "sets Portal.enewsSubscriptionEnabled to false" do
      allow(ENV).to receive(:[]).with("ENEWS_API_KEY").and_return('12345')
      render partial: 'dynamic_scripts/all'
      expect(rendered).to match 'Portal.enewsSubscriptionEnabled = true'
    end
  end
end
