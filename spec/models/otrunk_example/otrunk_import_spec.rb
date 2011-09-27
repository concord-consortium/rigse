require File.expand_path('../../../spec_helper', __FILE__)

describe OtrunkExample::OtrunkImport do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :classname => "value for classname",
      :fq_classname => "value for fq_classname"
    }
  end

  it "should create a new instance given valid attributes" do
    OtrunkExample::OtrunkImport.create!(@valid_attributes)
  end
end
