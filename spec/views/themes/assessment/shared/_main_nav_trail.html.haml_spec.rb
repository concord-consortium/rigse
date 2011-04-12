require 'spec_helper'

describe "/shared/_main_nav_trail.html.haml" do
  include ApplicationHelper

  before(:each) do
    ApplicationController.set_theme("assessment")
    @user = Factory.create(:user)
    template.stub!(:current_user).and_return(@user)
  end

  it "should render the appropriate header nav links for a teacher" do
    @user.stub!(:portal_teacher).and_return(true)
    render
    # wrap the response body so that nth-child matching will work
    response.body = "<ul>" + response.body + "</ul>"
    response.should have_tag("li:nth-child(3) a[href=?]", external_activities_path, :text => "Activities")
    response.should have_tag("li:nth-child(5):last-child a[href=?]", investigations_path, :text => "Investigations")
  end
end
