require File.expand_path('../../../spec_helper', __FILE__)

def inspect_course(c)
  # puts "curse: #{c.course_number} #{c.name} school: #{c.school.id} <br/>\n"
end

describe Portal::Course do
  before(:each) do
    @course_number = "COURZ_1"
    @school = Factory(:portal_school)
    @course_with_number = Factory(:portal_course, 
    {
      :course_number => @course_number,
      :name=>'with number',
      :school => @school
    })
    @course_without_number = Factory(:portal_course,
      {
        :course_number => nil,
        :name=> 'without number',
        :school => @school
    })
    @course_with_number.save
    @course_without_number.save
    
    [@course_with_number,@course_without_number].each do |course|
      inspect_course(course)
    end
    expect(@course_without_number.course_number).to be_nil
    expect(@course_with_number.course_number).not_to be_nil
  end
  
  describe "We should be able to find a course by course number and school id" do
    it "We should find a course for a valid course number and school id" do
      found = Portal::Course.find_by_course_number_and_school_id(@course_number,@school.id)
      expect(found).not_to be_nil
    end

    it "We should not find a course for non-existant course numbers" do
      found = Portal::Course.find_by_course_number_and_school_id("PING_PONG",@school.id)
      expect(found).to be_nil
      
      found = Portal::Course.find_by_course_number_and_school_id(@course_number,23)
      expect(found).to be_nil
    end
  end

  describe "We should be able to find a course using a course number, name and school id" do
    it "We should be able to find a course with the same number,name and school_id" do
      found = Portal::Course.find_by_course_number_name_and_school_id(@course_number,"with number",@school.id)
      expect(found).not_to be_nil
      expect(found.id).to be(@course_with_number.id)
    end
    it "We should be able to find a course with the same number,a new (differing) name and school_id" do
      found = Portal::Course.find_by_course_number_name_and_school_id(@course_number,"new name for the course",@school.id)
      expect(found).not_to be_nil
      expect(found.id).to be(@course_with_number.id)
    end
    
    it "We should be able to find a course with no course number, but with the same name and school_id" do
      found = Portal::Course.find_by_course_number_name_and_school_id("NEW_COURSE_NUMBER","without number",@school.id)
      expect(found).not_to be_nil
      expect(found.id).to be(@course_without_number.id)
      expect(found.course_number).to be_nil
    end
    
    it "We should not find a course with found name, and schoold_id but differing course_number" do
      found = Portal::Course.find_by_course_number_name_and_school_id("BAD_COURSE_NUMBER","with number",@school.id)
      expect(found).to be_nil
    end
  end

  describe "We should be able to find or create course using a course number, name and school id" do
    it "We should be able to find a course with the same number,name and school_id" do
      found = Portal::Course.find_or_create_by_course_number_name_and_school_id(@course_number,"with number",@school.id)
      expect(found).not_to be_nil
      expect(found.id).to be(@course_with_number.id)
    end
    it "We should be able to find a course with the same number,and give it a new name" do
      new_name = "new name for the course"
      found = Portal::Course.find_or_create_by_course_number_name_and_school_id(@course_number,new_name,@school.id)
      expect(found).not_to be_nil
      expect(found.id).to be(@course_with_number.id)
      expect(found.name).to be(new_name)
    end
    
    it "We should be able to find a course with no previous course number, but with the same name, and assign the new number" do
      new_course_number="NEW_COURSE_NUMBER"
      found = Portal::Course.find_or_create_by_course_number_name_and_school_id(new_course_number,"without number",@school.id)
      expect(found).not_to be_nil
      expect(found.id).to be(@course_without_number.id)
      expect(found.course_number).to be(new_course_number)
    end
    
    it "We should create a new course with a new name and number schoold_id but differing course_number" do
      new_course_number="NEW_C_NMBR"
      new_course_name = "new course name"
      found = Portal::Course.find_or_create_by_course_number_name_and_school_id(new_course_number,new_course_name,@school.id)
      expect(found).not_to be_nil
      expect(found.id).not_to be(@course_without_number.id)
      expect(found.id).not_to be(@course_with_number.id)
      expect(found.name).to be(new_course_name)
      expect(found.course_number).to be(new_course_number)
    end
    
    it "We should create a new course with a new name and number, even if the name matches an existing name" do
      new_course_number="NEW_C_NMBR"
      existing_name = "with number"
      found = Portal::Course.find_or_create_by_course_number_name_and_school_id(new_course_number,existing_name,@school.id)
      expect(found).not_to be_nil
      expect(found.id).not_to be(@course_without_number.id)
      expect(found.id).not_to be(@course_with_number.id)
      expect(found.name).to be(existing_name)
      expect(found.course_number).to be(new_course_number)
    end
    
    it "We should create a new course witht the SAME name and SAME number, but with a differing school.id" do
      new_course_number="NEW_C_NMBR"
      existing_name = "with number"
      found = Portal::Course.find_or_create_by_course_number_name_and_school_id(@course_with_number.course_number, @course_with_number.name, 777)
      expect(found).not_to be_nil
      expect(found.id).not_to equal(@course_without_number.id)
      expect(found.id).not_to equal(@course_with_number.id)
      expect(found.name).to equal(@course_with_number.name)
      expect(found.course_number).to equal(@course_with_number.course_number)
      expect(found.school_id).to equal(777)
    end
    
    
  end
  
  
end
