require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OtrunkExample::OtmlFile do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :otml_category_id => 1,
      :name => "value for name",
      :path => "value for path",
      :content => "value for content"
    }
  end

  it "should create a new instance given valid attributes" do
    OtrunkExample::OtmlFile.create!(@valid_attributes)
  end
end
