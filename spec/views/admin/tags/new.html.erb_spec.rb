require 'spec_helper'

describe "/admin/tags/new.html.haml" do
  include Admin::TagsHelper

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    template.stub!(:current_user).and_return(power_user)
    assigns[:admin_tag] = stub_model(Admin::Tag,
      :new_record? => true,
      :scope => "value for scope",
      :tag => "value for tag"
    )
  end

  it "renders new tags form" do
    render

    response.should have_tag("form[action=?][method=post]", admin_tags_path) do
      with_tag("input#admin_tag_scope[name=?]", "admin_tag[scope]")
      with_tag("input#admin_tag_tag[name=?]", "admin_tag[tag]")
    end
  end
end
