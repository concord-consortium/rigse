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
    
  end

  describe "finding or creating clazzes based on course, section, and start" do

    it "given criterea that matches an existing class, it should return a matching clazz" do
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(
        @existing_clazz.course,
        @existing_clazz.section,
        @existing_clazz.start_time)
      
      found_clazz.id.should_not be_nil
      found_clazz.id.should eql(@existing_clazz.id)
      found_clazz.should eql(@existing_clazz)
      found_clazz.name.should_not be_nil
    end

    
    it "when creating a new clazz this way, the name should be default to the course name" do
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(@course,@section_b,@start_date)
      found_clazz.name.should eql(@course.name)
    end
       
    it "given criterea that does not match an existing class, it should return a new clazz" do
      found_clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(@course,@section_b,@start_date)
      found_clazz.id.should_not eql(@existing_clazz.id)
      found_clazz.should_not eql(@existing_clazz)
    end
  end
  
  describe "asking if a user is allowed to remove a teacher from a clazz instance" do
    before(:each) do
      User.destroy_all
      Portal::Teacher.destroy_all
      
      @teacher1 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher1"))
      @teacher2 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher2"))
    end
    
    it "under normal circumstances should say there is no reason admins cannot remove teachers" do
      admin_user = Factory.next(:admin_user)
      @existing_clazz.teachers = [@teacher1, @teacher2]
      @existing_clazz.reason_user_cannot_remove_teacher_from_class(admin_user, @teacher1).should == nil
    end
    
    it "under normal circumstances should say there is no reason authorized teachers cannot remove teachers" do
      @existing_clazz.teachers = [@teacher1, @teacher2]
      @existing_clazz.reason_user_cannot_remove_teacher_from_class(@teacher1.user, @teacher2).should == nil
    end
    
    it "should say it is illegal for an unauthorized user to remove a teacher" do
      random_user = Factory.next(:anonymous_user)
      @existing_clazz.teachers = [@teacher1, @teacher2]
      @existing_clazz.reason_user_cannot_remove_teacher_from_class(random_user, @teacher1).should == Portal::Clazz::ERROR_REMOVE_TEACHER_UNAUTHORIZED
    end
    
    it "should say it is illegal for a user to remove the last teacher" do
      admin_user = Factory.next(:admin_user)
      @existing_clazz.teachers = [@teacher1]
      @existing_clazz.reason_user_cannot_remove_teacher_from_class(admin_user, @teacher1).should == Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER
    end
    
    it "should say it is illegal for a user to remove themselves" do
      @existing_clazz.teachers = [@teacher1, @teacher2]
      @existing_clazz.reason_user_cannot_remove_teacher_from_class(@teacher1.user, @teacher1).should == Portal::Clazz::ERROR_REMOVE_TEACHER_CURRENT_USER
    end
  end
end
