require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::School do
  before(:each) do
    @valid_attributes = {
      :district_id => 1,
      :nces_school_id => 1,
      :name => "value for name",
      :description => "value for description",
      :uuid => "value for uuid"
    }
    @school = Factory(:nces_portal_school)
    @virtual_school = Factory(:portal_school)
  end

  it "should create a new instance given valid attributes" do
    Portal::School.create!(@valid_attributes)
  end
  
  it "should support virtual schools with no NCSES data" do
    @virtual_school.virtual?
  end
  
  it "should allow for real schools with NCES data" do
    @school.real?
  end
  
end
