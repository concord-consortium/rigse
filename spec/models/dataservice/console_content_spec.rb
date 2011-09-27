require File.expand_path('../../../spec_helper', __FILE__)

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
