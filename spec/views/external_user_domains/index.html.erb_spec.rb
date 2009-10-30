require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/external_user_domains/index.html.erb" do
  include ExternalUserDomainsHelper

  before(:each) do
    assigns[:external_user_domains] = [
      stub_model(ExternalUserDomain,
        :name => "value for name",
        :description => "value for description",
        :server_url => "value for server_url",
        :uuid => "value for uuid"
      ),
      stub_model(ExternalUserDomain,
        :name => "value for name",
        :description => "value for description",
        :server_url => "value for server_url",
        :uuid => "value for uuid"
      )
    ]
  end

  it "renders a list of external_user_domains" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
    response.should have_tag("tr>td", "value for server_url".to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
  end
end
