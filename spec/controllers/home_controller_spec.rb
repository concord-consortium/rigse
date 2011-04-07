require 'spec_helper'

describe HomeController do
  integrate_views

  before(:each) do
    @test_project = mock("project")
    controller.stub(:before_render) {
      response.template.stub(:current_project).and_return(@test_project)
    }
  end

  #Delete this example and add some real ones
  it "should use HomeController" do
    @test_project.stub(:home_page_content).and_return(nil)
    get :index
    controller.should be_an_instance_of(HomeController)
  end
  
  it "should display home page content from the current admin project" do
    # it appears that some previous tests leave a user logged in somehow
    # so we explicitly log in anonymous here
    login_anonymous
    content = "Test home page content"
    @test_project.stub(:home_page_content).and_return(content)
    
    get :index
    
    @response.body.should include(content)
  end

end
