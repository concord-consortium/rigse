require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe RiGse::ExpectationStem do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    RiGse::ExpectationStem.create!(@valid_attributes)
  end
end
