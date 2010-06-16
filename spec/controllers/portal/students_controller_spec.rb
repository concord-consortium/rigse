require 'spec_helper'

describe Portal::StudentsController do
  integrate_views
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end
  
  describe "POST create" do
    before(:each) do
      @params_for_creation = {
        :user => {
          :first_name => "Test",
          :last_name => "User",
          :password => "testpassword",
          :password_confirmation => "testpassword"
        },
        :clazz => {
          :class_word => "classword"
        }
      }
      
      @grade_level = Portal::GradeLevel.create({ :name => "9" }) # default grade level
      @clazz = Factory.create(:portal_clazz, :class_word => @params_for_creation[:clazz][:class_word])
    end
    
    it "creates a user and a student when given valid parameters" do
      current_user_count = User.count(:all)
      current_student_count = Portal::Student.count(:all)
      
      post :create, @params_for_creation
      
      User.count(:all).should == current_user_count + 1
      Portal::Student.count(:all).should == current_student_count + 1
    end
    
    it "does not create a user or a student when given invalid parameters" do
      @params_for_creation[:user][:password] = "wrong"
      
      current_user_count = User.count(:all)
      current_student_count = Portal::Student.count(:all)
      
      post :create, @params_for_creation
      
      User.count(:all).should == current_user_count
      Portal::Student.count(:all).should == current_student_count
    end
    
    it "does not fill in any security questions" do
      # this should ensure that the student will need to pick security questions
      # when a teacher creates a student, the student should have to pick security questions when they log in
      # when a student creates themselves, they need to log in after creation anyway and should see the security questions form
      post :create, @params_for_creation
      
      User.last.security_questions.should be_empty
    end
  end
end