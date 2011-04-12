require 'spec_helper'

describe "/shared/_activity_header.haml" do
  include ApplicationHelper

  before(:each) do
    ApplicationController.set_theme("assessment")
    @activity = Factory.create(:activity)
    @user = Factory.create(:user)
    @activity.user = @user
    assigns[:activity] = @activity
    template.stub!(:current_user).and_return(@user)
  end

  it "should only render an add button and a delete button" do
    render :locals => {:activity => @activity}
    response.should have_tag("div[id=?]", dom_id_for(@activity, :item)) do
      with_tag("div[class=?]", "action_menu_header_right") do
        with_tag("a:nth-child(1):first-child[name=?]", "add")
        with_tag("a:nth-child(2):last-child[title=?]", "delete activity")
      end
    end
  end

  it "should render a disabled add button when an activity exists" do
    @section = Factory.create(:section)
    @activity.sections << @section
    render :locals => {:activity => @activity}
    response.should have_tag("div[id=?]", dom_id_for(@activity, :item)) do
      with_tag("div[class=?]", "action_menu_header_right") do
        with_tag("a:nth-child(1):first-child[title=?]", "can't add sections")
        with_tag("a:nth-child(2):last-child[title=?]", "delete activity")
      end
    end
  end
end
