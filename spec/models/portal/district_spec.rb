require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::District do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
    }
  end

  it "should create a new instance given valid attributes" do
    Portal::District.create!(@valid_attributes)
  end
  
  it "should support virtual schools with no NCSES data" do
    Portal::District.create!(@valid_attributes).should be_virtual
  end
    
  it "can create schools from NCES school data " do
    nces_district = Factory(:portal_nces06_district)
    new_district = Portal::District.find_or_create_by_nces_district(nces_district)
    new_district.should_not be_nil
    new_district.should be_real # meaning has a real nces school
  end
  
end
