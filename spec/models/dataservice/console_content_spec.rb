require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Dataservice::ConsoleContent do
  before(:each) do
    @valid_attributes = {
      :body => "value for body"
    }
  end

  it "should create a new instance given valid attributes" do
    Dataservice::ConsoleContent.create!(@valid_attributes)
  end
end
