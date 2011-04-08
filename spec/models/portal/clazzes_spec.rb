require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::Clazz do
  describe "finding or creating clazzes based on course, section, and start" do
    before(:each) do
      @course = Factory(:portal_course)
      @start_date = DateTime.parse("2009-01-02")
      @section_a = "section a"
      @section_b = "section b"
      @existing_clazz = Factory(:portal_clazz, {
        :section => @section_a,
        :start_time => @start_date,
        :course => @course,
      })

    end

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
      @existing_clazz = Factory(:portal_clazz)
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
      @existing_clazz.reason_user_cannot_remove_teacher_from_class(random_user, @teacher1).should == Portal::Clazz::ERROR_UNAUTHORIZED
    end
    
    it "should say it is illegal for a user to remove the last teacher" do
      admin_user = Factory.next(:admin_user)
      @existing_clazz.teachers = [@teacher1]
      @existing_clazz.reason_user_cannot_remove_teacher_from_class(admin_user, @teacher1).should == Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER
    end
  end
  
  describe "#changeable?" do
    before(:each) do
      @existing_clazz = Factory.build(:portal_clazz)
    end

    it "is true for admins" do
      admin_user = Factory.next(:admin_user)
      @existing_clazz.changeable?(admin_user).should be_true
    end

    it "is true for class teacher" do
      @teacher = Factory.create(:portal_teacher)
      @existing_clazz.teachers = [@teacher]
      @existing_clazz.changeable?(@teacher.user).should be_true
    end

    it "is true for second class teacher" do
      @teacher1 = Factory.create(:portal_teacher)
      @teacher2 = Factory.create(:portal_teacher)
      @existing_clazz.teachers = [@teacher1, @teacher2]
      @existing_clazz.changeable?(@teacher2.user).should be_true
    end

    it "is false for non class teacher" do
      @teacher = Factory.create(:portal_teacher)
      @existing_clazz.changeable?(@teacher.user).should be_false
    end
  end

  describe "creating a new class" do
    before(:each) do
      User.destroy_all
      Portal::Teacher.destroy_all
      
      @teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "test_teacher"))
    end
    
    it "should require a school" do
      # params = {
      #   :name => "Test Class",
      #   :class_word => "123456",
      #   :teacher_id => @teacher.id
      # }
      # 
      # new_clazz = Portal::Clazz.new(params)
      # new_clazz.valid?.should == false
      # 
      # params[:semester_id] = @semester.id
      # 
      # new_clazz = Portal::Clazz.new(params)
      # new_clazz.valid?.should == true
    end
    
    it "should require at least one teacher" do
    end
  end

  describe ".default_class" do
    it "should return a portal clazz with default_class true" do
      default_class = Portal::Clazz.default_class
      default_class.should be_an_instance_of Portal::Clazz
      default_class.default_class.should be_true
    end

    it "should return the same portal clazz on second call" do
      default_clazz = Portal::Clazz.default_class
      default_clazz.should be_an_instance_of Portal::Clazz
      Portal::Clazz.default_class.should == default_clazz
    end
  end
end
