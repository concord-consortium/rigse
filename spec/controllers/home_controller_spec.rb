require File.expand_path('../../spec_helper', __FILE__)
describe HomeController do
  render_views

  before(:each) do
    @test_project = mock("project")
    controller.stub(:before_render) {
      controller.template.stub(:current_project).and_return(@test_project)
    }
  end

  #Delete this example and add some real ones
  it "should use HomeController" do
    @test_project.stub(:home_page_content).and_return(nil)
    @test_project.stub(:name).and_return("Test Project")
    get :index
    controller.should be_an_instance_of(HomeController)
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
    before(:each) do
      Admin::Project.stub(:default_project).and_return(@test_project)
    end
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
end
