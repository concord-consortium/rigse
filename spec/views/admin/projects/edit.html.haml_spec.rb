require 'spec_helper'

describe "/admin/projects/edit.html.haml" do
  include ApplicationHelper

  before(:each) do
    @pub_interval = 30000;
    @project = Factory.create(:admin_project)
    @project.pub_interval = @pub_interval
    assigns[:admin_project] = @project
    template.stub!(:current_user).and_return(Factory.next(:admin_user))
    render
  end

  it "should show the pub interval form label" do
    response.body.should match(/pub interval/i)
  end

  it "should show the pub interval field value" do
    response.body.should have_tag("input#admin_project_pub_interval")
  end

end
