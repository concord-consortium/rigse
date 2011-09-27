require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::UnifyingTheme do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    RiGse::UnifyingTheme.create!(@valid_attributes)
  end
end
