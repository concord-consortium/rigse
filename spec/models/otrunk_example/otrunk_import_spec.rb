require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
