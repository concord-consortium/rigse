require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  before(:each) do
    #mock_project #FIXME mock_project is undefined!
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end
  
  
  #Delete this example and add some real ones
  it "should use HomeController" do
    pending "Broken example"
    controller.should be_an_instance_of(HomeController)
  end

end
