require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_external_users/show.html.erb" do
  include Portal::ExternalUsersHelper
  before(:each) do
    assigns[:external_user] = @external_user = stub_model(Portal::ExternalUser,
      :external_user_domain_id => 1,
      :user_id => 1,
      :external_user_key => "value for external_user_key",
      :uuid => "value for uuid"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ external_user_key/)
    response.should have_text(/value\ for\ uuid/)
  end
end
