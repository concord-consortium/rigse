require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OtrunkExample::OtrunkViewEntry do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :otrunk_import_id => 1,
      :classname => "value for classname",
      :fq_classname => "value for fq_classname"
    }
  end

  it "should create a new instance given valid attributes" do
    OtrunkExample::OtrunkViewEntry.create!(@valid_attributes)
  end
end
