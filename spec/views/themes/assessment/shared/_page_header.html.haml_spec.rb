require 'spec_helper'

describe "/shared/_page_header.html.haml" do
  include ApplicationHelper

  before(:each) do
    ApplicationController.set_theme("assessment")
    @page = Factory.create(:page)
    @user = Factory.create(:user)
    @page.user = @user
    assigns[:page] = @page
    template.stub!(:current_user).and_return(@user)
  end

  it "should only render an add button and a delete button" do
    render :locals => {:page => @page}
    response.should have_tag("div[id=?]", dom_id_for(@page, :item)) do
      with_tag("div[class=?]", "action_menu_header_right") do
        with_tag("a:nth-child(1):first-child[name=?]", "add")
        with_tag("a:nth-child(2):last-child[title=?]", "delete page")
      end
    end
  end

  it "should render a limited add list" do
    render :locals => {:page => @page}
    response.should have_tag("div[id=?] ul", "add_menu") do
      with_tag("li:nth-child(1):first-child a", :text => Embeddable::MwModelerPage.display_name)
      with_tag("li:nth-child(2) a", :text => Embeddable::NLogoModel.display_name)
      with_tag("li:nth-child(3) a", :text => Embeddable::MultipleChoice.display_name)
      with_tag("li:nth-child(4):last-child a", :text => Embeddable::OpenResponse.display_name)
    end
  end
end
