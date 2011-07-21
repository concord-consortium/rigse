require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::GradeSpanExpectation do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    RiGse::GradeSpanExpectation.create!(@valid_attributes)
  end
end
