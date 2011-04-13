require 'spec_helper'

describe "/investigations/new.html.haml" do
  include ApplicationHelper

  before(:each) do
    ApplicationController.set_theme("assessment")
    @user = Factory.create(:user)
    template.stub!(:current_user).and_return(@user)

    assigns[:investigation] = @investigation = Investigation.new
  end

  it "should render the creation form pointing to the extended create path" do
    render
    response.should have_tag("form[action=?]", investigation_extended_create_path)
  end
end
