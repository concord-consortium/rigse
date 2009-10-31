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
  
  it "can create schools from NCES school data " do
    nces_school = Factory(:portal_nces06_school)
    new_school = Portal::School.find_or_create_by_nces_school(nces_school)
    new_school.should_not be_nil
    new_school.should be_real # meaning has a real nces school
  end
  
  it "should not allow a teacher to be added more than once" do
    school = Factory(:portal_school)
    school.members.should be_empty
    teacher = Factory(:portal_teacher)
    school.add_member(teacher)
    school.reload
    school.members.size.should eql 1
    school.add_member(teacher)
    
    school.members.size.should eql 1
    school.reload
    school.members.size.should eql 1
  end
  
end
