require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_external_users/index.html.erb" do
  include Portal::ExternalUsersHelper

  before(:each) do
    assigns[:portal_external_users] = [
      stub_model(Portal::ExternalUser,
        :external_user_domain_id => 1,
        :user_id => 1,
        :external_user_key => "value for external_user_key",
        :uuid => "value for uuid"
      ),
      stub_model(Portal::ExternalUser,
        :external_user_domain_id => 1,
        :user_id => 1,
        :external_user_key => "value for external_user_key",
        :uuid => "value for uuid"
      )
    ]
  end

  it "renders a list of portal_external_users" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for external_user_key".to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
  end
end
