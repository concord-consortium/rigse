require 'spec_helper'

describe "/admin/tags/new.html.haml" do
  include Admin::TagsHelper

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    view.stub!(:current_user).and_return(power_user)
    assign(:admin_tag, Factory.build(:admin_tag,
      :scope => "value for scope",
      :tag => "value for tag"
    ))
  end

  it "renders new tags form" do
    render

    debugger
    assert_select("form[action=?][method=post]", admin_tags_path) do
      assert_select("input#admin_tag_scope[name=?]", "admin_tag[scope]")
      assert_select("input#admin_tag_tag[name=?]", "admin_tag[tag]")
    end
  end
end
