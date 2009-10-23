require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::Clazz do
  before(:each) do
    @course = Factory(:portal_course)
    @start_date = Date.parse("2009-01-02") 
  end
  describe "finding or creating clazzes based on course, section, and start" do
    
    it "given criterea that matches an existing class, it should return a matching clazz" do
      section_a = "section a"
      existing_clazz = Factory(:portal_clazz, {
        :section => section_a,
        :start_time => @start_date
      })
      existing_clazz.save!
      @course.clazzes << existing_clazz
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(@course,section_a,@start_date)
      found_clazz.save!
      found_clazz.id.should eql existing_clazz.id
      found_clazz.should eql existing_clazz
    end

    it "given criterea that does not match an existing class, it should return a nes clazz" do
      section_a = "section a"
      section_b = "section b"
      existing_clazz = Factory(:portal_clazz, {
        :section => section_a,
        :start_time => @start_date
      })
      existing_clazz.save!
      @course.clazzes << existing_clazz
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(@course,section_b,@start_date)
      found_clazz.save!
      found_clazz.id.should.not eql existing_clazz.id
      found_clazz.should.not eql existing_clazz
    end
  end
end
