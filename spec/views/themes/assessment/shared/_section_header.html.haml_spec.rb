require 'spec_helper'

describe "/shared/_section_header.html.haml" do
  include ApplicationHelper

  before(:each) do
    ApplicationController.set_theme("assessment")
    @activity = Factory.create(:activity)
    @section = Factory.create(:section)
    @section.activity = @activity
    @user = Factory.create(:user)
    @section.user = @user
    assigns[:section] = @section
    template.stub!(:current_user).and_return(@user)
  end

  it "should only render an add button and a delete button" do
    render :locals => {:section => @section}
    response.should have_tag("div[id=?]", dom_id_for(@section, :item)) do
      with_tag("div[class=?]", "action_menu_header_right") do
        with_tag("a:nth-child(1):first-child[name=?]", "add")
        with_tag("a:nth-child(2):last-child[title=?]", "delete section")
      end
    end
  end

  it "should render a disabled add button when a page exists" do
    @page = Factory.create(:page)
    @section.pages << @page
    render :locals => {:section => @section}
    response.should have_tag("div[id=?]", dom_id_for(@section, :item)) do
      with_tag("div[class=?]", "action_menu_header_right") do
        with_tag("a:nth-child(1):first-child[title=?]", "can't add pages")
        with_tag("a:nth-child(2):last-child[title=?]", "delete section")
      end
    end
  end
end
