require 'spec_helper'

describe JnlpAdaptor do

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    @project = Admin::Project.default_project
  end

  it "should create a new instance given valid attributes" do
    JnlpAdaptor.new(@project)
  end
  
  describe "should usefull describe itself" do
    before(:each) do
      @jnlp_adaptor = JnlpAdaptor.new(@project)
    end
    
    it "should return the otrunk netlogo pakage name" do
      @jnlp_adaptor.net_logo_package_name.should == "otrunknl41"
    end
  end

end
