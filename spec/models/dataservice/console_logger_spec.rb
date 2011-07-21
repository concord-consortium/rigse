require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::ConsoleLogger do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Dataservice::ConsoleLogger.create!(@valid_attributes)
  end
end
