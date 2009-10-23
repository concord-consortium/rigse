require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_external_users/new.html.erb" do
  include Portal::ExternalUsersHelper

  before(:each) do
    assigns[:external_user] = stub_model(Portal::ExternalUser,
      :new_record? => true,
      :external_user_domain_id => 1,
      :user_id => 1,
      :external_user_key => "value for external_user_key",
      :uuid => "value for uuid"
    )
  end

  it "renders new external_user form" do
    render

    response.should have_tag("form[action=?][method=post]", portal_external_users_path) do
      with_tag("input#external_user_external_user_domain_id[name=?]", "external_user[external_user_domain_id]")
      with_tag("input#external_user_user_id[name=?]", "external_user[user_id]")
      with_tag("input#external_user_external_user_key[name=?]", "external_user[external_user_key]")
      with_tag("input#external_user_uuid[name=?]", "external_user[uuid]")
    end
  end
end
