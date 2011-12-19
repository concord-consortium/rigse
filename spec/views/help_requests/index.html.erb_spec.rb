require 'spec_helper'

describe "/help_requests/index.html.haml" do
  include HelpRequestsHelper

  describe "as a manager" do
    before(:each) do
      user = stub_model(User, :has_role? => true)
      template.stub!(:current_user).and_return(user)
      template.stub!(:will_paginate).and_return("")
      assigns[:help_requests] = [
        stub_model(HelpRequest,
          :name => "value for name",
          :email => "value for email",
          :class_name => "value for class_name",
          :activity => "value for activity",
          :num_students => 1,
          :computer_type => "value for computer_type",
          :problem_type => "value for problem_type",
          :all_computers => nil,
          :pre_loaded => nil,
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
          :all_computers => nil,
          :pre_loaded => nil,
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
      response.should have_tag("tr>td",:text => "value for name",:count => 2)
      response.should have_tag("tr>td",:text => "value for email",:count => 2)
    end
  end

  describe "as a normal user" do
    before(:each) do
      @first_name = "firstName"
      @last_name = "lastName"
      @full_name = "#{@first_name} #{@last_name}"
      @email     = "fake@gmail.com"
      user = stub_model(User, {
        :has_role? => false,
        :last_name => @last_name,
        :first_name => @last_name,
        :email => @email})
      template.stub!(:current_user).and_return(user)
      @help_request = stub_model(HelpRequest, {
          :name => @full_name,
          :email => @email,
          :class_name => "value for class_name",
          :activity => "value for activity",
          :num_students => 1,
          :computer_type => "value for computer_type",
          :problem_type => "value for problem_type",
          :all_computers => nil,
          :pre_loaded => nil,
          :more_info => "value for more_info",
          :console => "value for console",
          :login => "value for login",
          :os => "value for os",
          :browser => "value for browser",
          :ip_address => "value for ip_address",
          :referrer => "value for referrer"
      })
      assigns[:help_request] = @help_request
    end

    it "renders the form for a help request" do
      render
      response.should have_tag("dd>input", :value => @full_name)
      response.should have_tag("dd>input", :value => @email)
    end
  end
end
