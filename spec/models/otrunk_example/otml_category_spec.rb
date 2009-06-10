require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OtrunkExample::OtmlCategory do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    OtrunkExample::OtmlCategory.create!(@valid_attributes)
  end
end
