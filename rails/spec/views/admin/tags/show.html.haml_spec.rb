require 'spec_helper'

describe "/admin/tags/show.html.haml" do
  include Admin::TagsHelper
  before(:each) do
    # TODO: Find out why the next line is needed for these tests to pass. Since the upgrade from Rails v6.1 to 7.0
    # the tests will fail without it. It has something to do with the partials rendered in the view. Rails
    # can't seem to find the partial files without specifying the subdirectory in app/views here.
    view.lookup_context.prefixes << "admin/tags"
    power_user = stub_model(User, :has_role? => true)
    allow(view).to receive(:current_visitor).and_return(power_user)
    @admin_tag = stub_model(Admin::Tag,
      :scope => "value for scope",
      :tag => "value for tag")
    assign(:admin_tag, @admin_tag)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/value for scope/)
    expect(rendered).to match(/value for tag/)
  end
end
