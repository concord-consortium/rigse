require 'spec_helper'

describe "/shared/_general_accordion_nav.html.haml" do
  include ApplicationHelper

  before(:each) do
    ApplicationController.set_theme("assessment")
    @investigation = Factory.create(:investigation)
    @activity = Factory.create(:activity)
    @section = Factory.create(:section)
    @page = Factory.create(:page)
    @user = Factory.create(:user)
    @investigation.user = @user
    @activity.user = @user
    @section.user = @user
    @page.user = @user
    @investigation.activities << @activity
    @activity.sections << @section
    @section.pages << @page
    @investigation.name = @name = "Test"
    @link_title = "Preview the Investigation: 'Test' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
    assigns[:investigation] = @investigation
    template.stub!(:current_user).and_return(@user)
  end

  it "should render the preview link in the default theme" do
    ApplicationController.set_theme("default")
    render :locals => {:top_node => @investigation, :selects => []}
    response.should have_tag("div[class=?][id=?]", "accordion_header", dom_id_for(@investigation, :accordion_container_list)) do
      with_tag("a[title=?]", @link_title)
    end
  end

  it "should not render the preview link in the assessment theme" do
    render :locals => {:top_node => @investigation, :selects => []}
    response.should have_tag("div[class=?][id=?]", "accordion_header", dom_id_for(@investigation, :accordion_container_list)) do
      without_tag("a[title=?]", @link_title)
    end
  end
end
