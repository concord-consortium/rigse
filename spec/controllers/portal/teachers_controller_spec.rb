require 'spec_helper'

describe Portal::TeachersController do
  integrate_views
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  describe "POST create" do
    it "should create a user and a teacher if all fields are valid" do
      params = {
        :user => {
          :first_name => "Test",
          :last_name => "Teacher",
          :email => "test@fake.edu",
          :login => "tteacher",
          :password => "password",
          :password_confirmation => "password"
        },
        :school => {
          :id => Factory.create(:portal_school).id
        },
        :grade => {
          :id => Factory.create(:portal_grade).id
        }
      }
      
      current_user_count = User.count(:all)
      current_teacher_count = Portal::Teacher.count(:all)
      
      post :create, params
      @response.should render_template("users/thanks")
      
      assert_equal User.count(:all), current_user_count + 1, "TeachersController#create did not create a User when given valid POST data"
      assert_equal Portal::Teacher.count(:all), current_teacher_count + 1, "TeachersController#create did not create a Portal::Teacher when given valid POST data"
      assert_nil flash[:error]
      assert_nil flash[:notice]
    end
    
    it "should not allow the teacher not to select a school" do
      params = {
        :user => {
          :first_name => "Test",
          :last_name => "Teacher",
          :email => "test@fake.edu",
          :login => "tteacher",
          :password => "password",
          :password_confirmation => "password"
        },
        :school => {
          :id => ""
        },
        :grade => {
          :id => Factory.create(:portal_grade).id
        }
      }
      
      current_user_count = User.count(:all)
      current_teacher_count = Portal::Teacher.count(:all)
      
      post :create, params
      
      assert_equal User.count(:all), current_user_count, "TeachersController#create erroneously created a User when given invalid POST data"
      assert_equal Portal::Teacher.count(:all), current_teacher_count, "TeachersController#create erroneously created a Portal::Teacher when given invalid POST data"
      assert_not_nil flash[:error]
      assert_nil flash[:notice]
      @response.body.should include("must select a school")
    end
  end

end