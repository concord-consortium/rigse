require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::TeachersController do
  render_views
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
  end

  before(:each) do
    @school   = Factory.create(:portal_school)
    @selector = Portal::SchoolSelector.new({
      :country => Portal::SchoolSelector::USA,
      :state   => 'MA'})
    @selector.stub!(:valid?).and_return true
    @selector.school = @school
    @selector.district = @school.district
    Portal::SchoolSelector.stub!(:new).and_return(@selector) 
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
    
    it "should not force the teacher not to select a school" do
      params = {
        :user => {
          :first_name => "Test",
          :last_name => "Teacher",
          :email => "test@fake.edu",
          :login => "tteacher",
          :password => "password",
          :password_confirmation => "password"
        }
      }
      @selector.stub!(:valid?).and_return false
      current_user_count = User.count(:all)
      current_teacher_count = Portal::Teacher.count(:all)
      
      post :create, params
      
      assert_equal User.count(:all), current_user_count, "TeachersController#create erroneously created a User when given invalid POST data"
      assert_equal Portal::Teacher.count(:all), current_teacher_count, "TeachersController#create erroneously created a Portal::Teacher when given invalid POST data"
      #assert_not_nil flash.now[:error]
      assert_nil flash[:notice]
      @response.body.should include("must select a school")
      @response.body.should include("Sorry")
    end
  end
  
end
