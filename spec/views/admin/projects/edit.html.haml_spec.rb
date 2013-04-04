require 'spec_helper'

describe "/admin/projects/edit.html.haml" do
  include ApplicationHelper

  before(:each) do
    @pub_interval = 30000;
    @project = Admin::Project.new(:pub_interval => @pub_interval)
    assign(:admin_project,@project)
    view.stub!(:current_visitor).and_return(Factory.next(:admin_user))
    render
  end

  it "should show the pub interval form label" do
    rendered.should match(/pub interval/i)
  end

  it "should show the pub interval field value" do
    rendered.should have_selector("input#admin_project_pub_interval")
  end

end
