require 'spec_helper'

describe "/shared/_investigation_header.html.haml" do
  include ApplicationHelper

  before(:each) do
    ApplicationController.set_theme("assessment")
    @investigation = Factory.create(:investigation)
    @user = Factory.create(:user)
    @investigation.user = @user
    assigns[:investigation] = @investigation
    template.stub!(:current_user).and_return(@user)
  end

  it "should only render an add button and a delete button" do
    render :locals => {:investigation => @investigation}
    response.should have_tag("div[id=?]", dom_id_for(@investigation, :item)) do
      with_tag("div[class=?]", "action_menu_header_right") do
        with_tag("a:nth-child(1):first-child[name=?]", "add")
        with_tag("a:nth-child(2):last-child[title=?]", "delete investigation")
      end
    end
  end

  it "should render a disabled add button when an activity exists" do
    @activity = Factory.create(:activity)
    @investigation.activities << @activity
    render :locals => {:investigation => @investigation}
    response.should have_tag("div[id=?]", dom_id_for(@investigation, :item)) do
      with_tag("div[class=?]", "action_menu_header_right") do
        with_tag("a:nth-child(1):first-child[title=?]", "can't add activities")
        with_tag("a:nth-child(2):last-child[title=?]", "delete investigation")
      end
    end
  end
end
