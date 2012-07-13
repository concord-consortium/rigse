require File.expand_path('../../spec_helper', __FILE__)

describe JnlpAdaptor do

  before(:each) do
    generate_default_project_and_jnlps_with_factories
  end

  it "should create a new instance given valid attributes" do
    JnlpAdaptor.new
  end
  
  describe "should usefull describe itself" do
    before(:each) do
      @jnlp_adaptor = JnlpAdaptor.new
    end
    
    it "should return the otrunk netlogo pakage name" do
      @jnlp_adaptor.net_logo_package_name.should == "otrunknl41"
    end
  end

end
