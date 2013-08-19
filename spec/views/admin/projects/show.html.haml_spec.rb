require 'spec_helper'

describe "/admin/projects/show.html.haml" do
  include ApplicationHelper

  before(:each) do
    @pub_interval = 30000;
    @project = Factory.create(:admin_project)
    @project.pub_interval = @pub_interval
    assigns[:admin_project] = @project
    template.stub!(:current_user).and_return(Factory.next(:admin_user))
    render
  end

  it "should show the pub interval" do
    response.body.should match(/pub interval/i)
    response.body.should match(/#{@pub_interval.to_s}/)
  end

end
