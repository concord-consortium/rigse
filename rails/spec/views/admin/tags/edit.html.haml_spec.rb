require 'spec_helper'

describe "/admin/tags/edit.html.haml" do
  include Admin::TagsHelper

  before(:each) do
    # RAILS-UPGRADE-TODO: Find out why the next line is needed for these tests to pass. Since the upgrade from Rails v6.1 to 7.0
    # the tests will fail without it. It has something to do with the partials rendered in the view. Rails
    # can't seem to find the partial files without specifying the subdirectory in app/views here.
    view.lookup_context.prefixes << "admin/tags"
    power_user = stub_model(User, :has_role? => true)
    allow(view).to receive(:current_visitor).and_return(power_user)
    assign(:admin_tag, @admin_tag = stub_model(Admin::Tag,
      :new_record? => false,
      :scope => "value for scope",
      :tag => "value for tag"
    ))
  end

  it "renders the edit tags form" do
    render
    assert_select("form[action=\"#{admin_tag_path(@admin_tag)}\"][method=post]") do
      assert_select('input#admin_tag_scope[name=?]', "admin_tag[scope]")
      assert_select('input#admin_tag_tag[name=?]', "admin_tag[tag]")
    end
  end
end
