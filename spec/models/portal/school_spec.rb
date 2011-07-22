require File.expand_path('../../../spec_helper', __FILE__)

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
    school.members.size.should eql(1)
    school.add_member(teacher)
    
    school.members.size.should eql(1)
    school.reload
    school.members.size.should eql(1)
  end
  
  
  describe "ways to find schools" do
    before(:each) do
      @woonsocket_school = Factory(:portal_nces06_school, {
        :SEASCH => 39123,
        :MSTATE => 'RI',
        :SCHNAM => 'Woonsocket High School',
      })
      @school = Factory(:portal_school,{
        :nces_school_id => @woonsocket_school.id,
      })
    end
    
    describe "Given an NCES local school id that matches the SEASCH field in an NCES school" do
      it "finds and return the first school that is associated with the NCES school if one exists" do
        found = Portal::School.find_by_state_and_nces_local_id('RI', 39123)
        found.should_not be_nil
        found.should eql(@school)
      end
      it "returns nil if there is no matching school" do
        found = Portal::School.find_by_state_and_nces_local_id('MA', 39123)
        found.should be_nil
      end
    end
    describe "Given a school name that matches the SEASCH field in an NCES school " do
      it "finds and returns the first school that is associated with the NCES school name." do
        found = Portal::School.find_by_state_and_school_name('RI', "Woonsocket High School")
        found.should_not be_nil
        found.should eql(@school)
      end
      it "if there is no matching school, it should return nil" do
        found = Portal::School.find_by_state_and_school_name('RI', "Amherst Regional High School")
        found.should be_nil
      end
    end
  end
  
end
