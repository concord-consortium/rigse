require 'spec_helper'

describe "/help_requests/show.html.erb" do
  include HelpRequestsHelper
  before(:each) do
    assigns[:help_request] = @help_request = stub_model(HelpRequest,
      :name => "value for name",
      :email => "value for email",
      :class_name => "value for class_name",
      :activity => "value for activity",
      :num_students => 1,
      :computer_type => "value for computer_type",
      :problem_type => "value for problem_type",
      :all_computers => ,
      :pre_loaded => ,
      :more_info => "value for more_info",
      :console => "value for console",
      :login => "value for login",
      :os => "value for os",
      :browser => "value for browser",
      :ip_address => "value for ip_address",
      :referrer => "value for referrer"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ email/)
    response.should have_text(/value\ for\ class_name/)
    response.should have_text(/value\ for\ activity/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ computer_type/)
    response.should have_text(/value\ for\ problem_type/)
    response.should have_text(//)
    response.should have_text(//)
    response.should have_text(/value\ for\ more_info/)
    response.should have_text(/value\ for\ console/)
    response.should have_text(/value\ for\ login/)
    response.should have_text(/value\ for\ os/)
    response.should have_text(/value\ for\ browser/)
    response.should have_text(/value\ for\ ip_address/)
    response.should have_text(/value\ for\ referrer/)
  end
end
