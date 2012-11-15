require File.expand_path('../../spec_helper', __FILE__)
describe HomeController do
  render_views

  before(:each) do
    @test_project = mock("project")
    Admin::Project.stub(:default_project).and_return(@test_project)
    @test_project.stub!(:use_student_security_questions).and_return(false)
    @test_project.stub!(:require_user_consent?).and_return(false)
    @test_project.stub!(:help_type).and_return('no help')
    controller.stub(:before_render) {
      response.template.stub(:current_project).and_return(@test_project)
    }
  end

  it "should display home page content from the current admin project" do
    # it appears that some previous tests leave a user logged in somehow
    # so we explicitly log in anonymous here
    login_anonymous
    content = "Test home page content"
    @test_project.stub(:home_page_content).and_return(content)
    @test_project.stub(:name).and_return("Test Project")
    
    get :index
    
    @response.body.should include(content)
  end

  describe "GET /stylesheets/project.css" do
    describe "when a project is configured to use custom styles" do
      it "should return the custom css" do
        css_text = ".some_class { font-height: 10px; }"
        @test_project.stub(:custom_css).and_return(css_text)
        @test_project.stub(:using_custom_css?).and_return(true)
        get :project_css
        response.body.should include(css_text)
      end
    end
    describe "when a project is not configuted to use custom styles" do
      it "should return 404" do
        @test_project.stub(:using_custom_css?).and_return(false)
        get :project_css
        response.should_not be_success
      end
    end
  end
  describe "Post preview_home_page" do
    it "should set variables to preview home page" do
      anonymous_user = Factory.next(:anonymous_user)
      @post_params = {
        :home_page_preview_content =>"<b>Home page content.</b>",
      }
      post :preview_home_page, @post_params
      assert_response :success
      assert_template 'preview_home_page'
      assert_not_nil assigns[:home_page_preview_content]
      assert_equal assigns[:home_page_preview_content], @post_params[:home_page_preview_content]
      assert_equal assigns[:preview_home_page_content], true
      assert_equal assigns[:wide_content_layout], true
    end
  end
end
