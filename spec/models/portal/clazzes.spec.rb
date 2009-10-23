require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::Clazz do
  before(:each) do
    @course = Factory(:portal_course)
    @start_date = DateTime.parse("2009-01-02")
    @section_a = "section a"
    @section_b = "section b"
    @existing_clazz = Factory(:portal_clazz, {
      :section => @section_a,
      :start_time => @start_date,
      :course => @course
    })
    puts "curse: #{@course.inspect}"
    
  end

  describe "finding or creating clazzes based on course, section, and start" do

    it "given criterea that matches an existing class, it should return a matching clazz" do
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(
        @existing_clazz.course,
        @existing_clazz.section,
        @existing_clazz.start_time)
      
      found_clazz.id.should_not be_nil
      found_clazz.id.should eql @existing_clazz.id
      found_clazz.should eql @existing_clazz
      found_clazz.name.should_not be_nil
    end

    
    it "when creating a new clazz this way, the name should be default to the course name" do
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(@course,@section_b,@start_date)
      found_clazz.name.should eql @course.name
    end
       
    it "given criterea that does not match an existing class, it should return a new clazz" do
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(@course,@section_b,@start_date)
      found_clazz.id.should_not eql @existing_clazz.id
      found_clazz.should_not eql @existing_clazz
    end
  end
end
