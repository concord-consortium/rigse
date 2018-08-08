require 'spec_helper'

describe "/admin/settings/edit.html.haml" do
  include ApplicationHelper

  before(:each) do
    @pub_interval = 30000;
    @settings = Admin::Settings.new(:pub_interval => @pub_interval)
    assign(:admin_settings,@settings)
    allow(view).to receive(:current_visitor).and_return(Factory.next(:admin_user))
    render
  end

  it "should show the pub interval form label" do
    expect(rendered).to match(/pub interval/i)
  end

  it "should show the pub interval field value" do
    expect(rendered).to have_selector("input#admin_settings_pub_interval")
  end

end
