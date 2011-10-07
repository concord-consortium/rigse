require 'spec_helper'

describe "/help_requests/index.html.erb" do
  include HelpRequestsHelper

  before(:each) do
    assigns[:help_requests] = [
      stub_model(HelpRequest,
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
      ),
      stub_model(HelpRequest,
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
    ]
  end

  it "renders a list of help_requests" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for email".to_s, 2)
    response.should have_tag("tr>td", "value for class_name".to_s, 2)
    response.should have_tag("tr>td", "value for activity".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for computer_type".to_s, 2)
    response.should have_tag("tr>td", "value for problem_type".to_s, 2)
    response.should have_tag("tr>td", .to_s, 2)
    response.should have_tag("tr>td", .to_s, 2)
    response.should have_tag("tr>td", "value for more_info".to_s, 2)
    response.should have_tag("tr>td", "value for console".to_s, 2)
    response.should have_tag("tr>td", "value for login".to_s, 2)
    response.should have_tag("tr>td", "value for os".to_s, 2)
    response.should have_tag("tr>td", "value for browser".to_s, 2)
    response.should have_tag("tr>td", "value for ip_address".to_s, 2)
    response.should have_tag("tr>td", "value for referrer".to_s, 2)
  end
end
