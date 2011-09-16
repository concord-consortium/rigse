require File.expand_path('../../../spec_helper', __FILE__)

describe Blog::BlogsController do
  
  before(:each) do
    generate_default_project_and_jnlps_with_factories
    @project = Admin::Project.default_project
    
    @project.rpc_admin_login = "login"
    @project.rpc_admin_email = "email"
    @project.rpc_admin_password = "password"
    @project.word_press_url = "http://example.com"
    @project.save
    
    @user_id_response = mock(Net::HTTPOK, :code => 200, :body => "<string>200</string>")
    @user_id_error_response = mock(Net::HTTPOK, :code => 200, :body => "<string></string>")
    @content_post_response = mock(Net::HTTPOK, :code => 200, :body => "<string>384</string>")

    @post_params = {
      :blog_name => "myblog",
      :post_title => "This is my post title",
      :post_content => "This is some extended content.\nIt should look nice!"
    }

    @http_mock = mock(Net::HTTP)
  end
  
  describe "POST post_blog" do    
    it "skips posting to blog is rpc is not set" do
      @project.rpc_admin_login = nil
      @project.rpc_admin_email = nil
      @project.rpc_admin_password = nil
      @project.word_press_url = nil
      @project.save
        
      Net::HTTP.should_not_receive(:new)
      post :post_blog, @post_params
      response.should_not be_success
      response.code.to_i.should == 404
    end
  
    it "posts a blog as the current user" do
      Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
      @http_mock.should_receive(:start).twice.and_yield(@http_mock)
      @http_mock.should_receive(:request).twice.and_return(@user_id_response, @content_post_response)
      post :post_blog, @post_params
      response.should be_success
    end
  
    it "returns an error when the current user doesn't exist in the blog" do
      Net::HTTP.should_receive(:new).once.and_return(@http_mock)
      @http_mock.should_receive(:start).once.and_yield(@http_mock)
      @http_mock.should_receive(:request).once.and_return(@user_id_error_response)
      post :post_blog, @post_params
      response.should_not be_success
      response.code.to_i.should == 404
    end
  end
  
  describe "Creating a WP blog" do
    before(:each) do
      @controller = Portal::ClazzesController.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new

      @mock_semester = Factory.create(:portal_semester, :name => "Fall")
      @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])

      # set up our user types
      @normal_user = Factory.next(:anonymous_user)
      @admin_user = Factory.next(:admin_user)
      @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "authorized_teacher"), :schools => [@mock_school])
      # @unauthorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "unauthorized_teacher"), :schools => [@mock_school])

      @authorized_teacher_user = @authorized_teacher.user

      @mock_clazz_name = "Random Test Class"
      @mock_course = Factory.create(:portal_course, :name => @mock_clazz_name, :school => @mock_school)
      # @mock_clazz = mock_clazz({ :name => @mock_clazz_name, :teachers => [@authorized_teacher], :course => @mock_course })
      
    end
    
    it "should create a wp blog when a class is created" do
      Net::HTTP.should_receive(:new).once.and_return(@http_mock)
      @http_mock.should_receive(:start).once.and_yield(@http_mock)
      @http_mock.should_receive(:request).once
      
      clazz = Factory.create(:portal_clazz, :name => "My class", :teacher => @authorized_teacher, :teacher_id => @authorized_teacher.id, :course => @mock_course, :class_word => "word")
    end
  end
end
