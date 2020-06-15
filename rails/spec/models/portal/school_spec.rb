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
    @school = FactoryBot.create(:nces_portal_school)
    @virtual_school = FactoryBot.create(:portal_school)
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
    nces_school = FactoryBot.create(:portal_nces06_school)
    new_school = Portal::School.find_or_create_using_nces_school(nces_school)
    expect(new_school).not_to be_nil
    expect(new_school).to be_real # meaning has a real nces school
  end
  
  it "should not allow a teacher to be added more than once" do
    school = FactoryBot.create(:portal_school)
    expect(school.members).to be_empty
    teacher = FactoryBot.create(:portal_teacher)
    school.add_member(teacher)
    school.reload
    expect(school.members.size).to eql(1)
    school.add_member(teacher)
    
    expect(school.members.size).to eql(1)
    school.reload
    expect(school.members.size).to eql(1)
  end

  describe "#portal_teachers" do
    it "should be writable" do
      school = FactoryBot.create(:portal_school)
      expect(school.members).to be_empty
      teacher = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:user, :login => "authorized_teacher"))

      school.portal_teachers << teacher

      expect(school.members.size).to eq(1)
      expect(school.portal_teachers.size).to eq(1)
      school.reload
      expect(school.members.size).to eq(1)
      expect(school.portal_teachers.size).to eq(1)
    end

    it "should only return teachers" do
      school = FactoryBot.create(:portal_school)
      expect(school.members).to be_empty
      teacher = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:user, :login => "authorized_teacher"), :schools => [school])

      # we actually don't add students to schools anymore but in case we start doing it again
      student = FactoryBot.create(:portal_student)
      Portal::SchoolMembership.create(:school => school, :member => student)

      school.reload
      expect(school.members.size).to eq(2)
      expect(school.portal_teachers.size).to eq(1)
    end
  end
  
  describe "ways to find schools" do
    before(:each) do
      @woonsocket_school = FactoryBot.create(:portal_nces06_school, {
        :SEASCH => 39123,
        :MSTATE => 'RI',
        :SCHNAM => 'Woonsocket High School',
      })
      @school = FactoryBot.create(:portal_school,{
        :nces_school_id => @woonsocket_school.id,
      })
    end
    
    describe "Given an NCES local school id that matches the SEASCH field in an NCES school" do
      it "finds and return the first school that is associated with the NCES school if one exists" do
        found = Portal::School.find_by_state_and_nces_local_id('RI', 39123)
        expect(found).not_to be_nil
        expect(found).to eql(@school)
      end
      it "returns nil if there is no matching school" do
        found = Portal::School.find_by_state_and_nces_local_id('MA', 39123)
        expect(found).to be_nil
      end
    end
    describe "Given a school name that matches the SEASCH field in an NCES school " do
      it "finds and returns the first school that is associated with the NCES school name." do
        found = Portal::School.find_by_state_and_school_name('RI', "Woonsocket High School")
        expect(found).not_to be_nil
        expect(found).to eql(@school)
      end
      it "if there is no matching school, it should return nil" do
        found = Portal::School.find_by_state_and_school_name('RI', "Amherst Regional High School")
        expect(found).to be_nil
      end
    end
  end
  
end
