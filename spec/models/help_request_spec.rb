require 'spec_helper'

describe HelpRequest do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :email => "value for email",
      :class_name => "value for class_name",
      :activity => "value for activity",
      :num_students => 1,
      :computer_type => "value for computer_type",
      :problem_type => "value for problem_type",
      :all_computers => true,
      :pre_loaded => true,
      :more_info => "value for more_info",
      :console => "value for console",
      :login => "value for login",
      :os => "value for os",
      :browser => "value for browser",
      :ip_address => "value for ip_address",
      :referrer => "value for referrer"
    }
  end

  it "should create a new instance given valid attributes" do
    HelpRequest.create!(@valid_attributes)
  end
end
