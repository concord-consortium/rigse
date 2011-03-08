require 'spec_helper'

describe HomeController do
  integrate_views

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    logout_user
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  #Delete this example and add some real ones
  it "should use HomeController" do
    get :index
    controller.should be_an_instance_of(HomeController)
  end
  
  it "should display home page content from the current admin project" do
    content = "Test home page content"
    @mock_project.stub!(:home_page_content).and_return(content)
    
    get :index
    
    @response.body.should include(content)
  end

end
