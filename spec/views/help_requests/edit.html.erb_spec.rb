require 'spec_helper'

describe "/help_requests/edit.html.erb" do
  include HelpRequestsHelper

  before(:each) do
    assigns[:help_request] = @help_request = stub_model(HelpRequest,
      :new_record? => false,
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

  it "renders the edit help_request form" do
    render

    response.should have_tag("form[action=#{help_request_path(@help_request)}][method=post]") do
      with_tag('input#help_request_name[name=?]', "help_request[name]")
      with_tag('input#help_request_email[name=?]', "help_request[email]")
      with_tag('input#help_request_class_name[name=?]', "help_request[class_name]")
      with_tag('input#help_request_activity[name=?]', "help_request[activity]")
      with_tag('input#help_request_num_students[name=?]', "help_request[num_students]")
      with_tag('input#help_request_computer_type[name=?]', "help_request[computer_type]")
      with_tag('input#help_request_problem_type[name=?]', "help_request[problem_type]")
      with_tag('input#help_request_all_computers[name=?]', "help_request[all_computers]")
      with_tag('input#help_request_pre_loaded[name=?]', "help_request[pre_loaded]")
      with_tag('textarea#help_request_more_info[name=?]', "help_request[more_info]")
      with_tag('textarea#help_request_console[name=?]', "help_request[console]")
      with_tag('input#help_request_login[name=?]', "help_request[login]")
      with_tag('input#help_request_os[name=?]', "help_request[os]")
      with_tag('input#help_request_browser[name=?]', "help_request[browser]")
      with_tag('input#help_request_ip_address[name=?]', "help_request[ip_address]")
      with_tag('textarea#help_request_referrer[name=?]', "help_request[referrer]")
    end
  end
end
