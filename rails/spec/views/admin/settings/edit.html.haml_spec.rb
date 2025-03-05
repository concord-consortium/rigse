require 'spec_helper'

describe "/admin/settings/edit.html.haml" do
  include ApplicationHelper

  before(:each) do
    # RAILS-UPGRADE-TODO: Find out why the next line is needed for these tests to pass. Since the upgrade from Rails v6.1 to 7.0
    # the tests will fail without it. It has something to do with the partials rendered in the view. Rails
    # can't seem to find the partial files without specifying the subdirectory in app/views here.
    view.lookup_context.prefixes << "admin/settings"
    @pub_interval = 30000;
    @settings = Admin::Settings.new(:pub_interval => @pub_interval)
    assign(:admin_settings,@settings)
    allow(view).to receive(:current_visitor).and_return(FactoryBot.generate(:admin_user))
    render
  end

  it "should show the pub interval form label" do
    expect(rendered).to match(/pub interval/i)
  end

  it "should show the pub interval field value" do
    expect(rendered).to have_selector("input#admin_settings_pub_interval")
  end

end
