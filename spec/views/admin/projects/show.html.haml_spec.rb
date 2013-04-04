require 'spec_helper'

describe "/admin/projects/show.html.haml" do
  include ApplicationHelper

  before(:each) do
    @pub_interval = 30000;
    @project = Admin::Project.new(:pub_interval => @pub_interval)
    assign(:admin_project,@project)
    view.stub!(:current_visitor).and_return(Factory.next(:admin_user))
    render
  end

  it "should show the pub interval" do
    rendered.should match(/pub interval/i)
    rendered.should match(/#{@pub_interval.to_s}/)
  end

end
