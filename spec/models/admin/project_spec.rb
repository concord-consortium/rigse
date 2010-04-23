require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# mock_admin_project
# mock_maven_jnlp_maven_jnlp_server
# mock_maven_jnlp_maven_jnlp_family
# mock_maven_jnlp_versioned_jnlp_url
# mock_maven_jnlp_versioned_jnlp

describe Admin::Project do
  before(:each) do
    @maven_jnlp_server = mock_maven_jnlp_maven_jnlp_server
    @maven_jnlp_family = mock_maven_jnlp_maven_jnlp_family
    @new_valid_project = Admin::Project.new(
      :name => "Example Project",
      :url => "http://rites.org",
      :states_and_provinces => %w{RI MA},
      :maven_jnlp_server_id => @maven_jnlp_server.id,
      :maven_jnlp_family_id => @maven_jnlp_family.id,
      :jnlp_version_str => mock_version_str,
      :snapshot_enabled => false
    )
  end

  it "should create a new instance given valid attributes" do
    @new_valid_project.should be_valid
  end

  it "should not create a new instance given an invalid server_url" do
    @new_valid_project.url = "ftp://rites.org"
    @new_valid_project.should_not be_valid
  end

  it "should not create a new instance given an empty name" do
    @new_valid_project.name = ""
    @new_valid_project.should_not be_valid
  end

  it "should not create a new instance given an invalid abbreviations in :states_and_provinces" do
    @new_valid_project.states_and_provinces = %w{RI MA ZZ}
    @new_valid_project.should_not be_valid
  end

  it "should not create a new instance if states_and_provinces is a hash" do
    @new_valid_project.states_and_provinces = {'RI' => 'Rhode Island', 'MA' => 'Massachusetts'}
    @new_valid_project.should_not be_valid
  end
  
  describe "a projects list of enabled vendor interfaces" do
    # create some fake vendor interfaces in the DB
    before(:all) do
      # remove old interfaces: (shouldn't this be rolled back anyway?)
      Probe::VendorInterface.find(:all).each { |vi| vi.destroy }
      @num_interfaces = 4
      @num_interfaces.times do |counter|
        interface_name = "fake-interface-#{counter}"
        Factory(:probe_vendor_interface, :name => interface_name)
      end
      @all_interfaces = Probe::VendorInterface.find(:all)
    end
    
    it "should have a sane testing environment" do
      @all_interfaces.should have(@num_interfaces).things
    end
    
    it "should exist" do
      @new_valid_project.enabled_vendor_interfaces.should_not be_nil
    end
    
    it "should initially have all the existant vendor interfaces" do
      @new_valid_project.enabled_vendor_interfaces.should have(@num_interfaces).things
      @all_interfaces.each do |interface|
        @new_valid_project.enabled_vendor_interfaces.should include interface
      end
    end
    
    it "should allow removing vendor interfaces" do
      interface_to_remove = Probe::VendorInterface.find(:first)
      @new_valid_project.save # delete throws an exception if our model doesn't have an id
      @new_valid_project.enabled_vendor_interfaces.delete(interface_to_remove)
      @new_valid_project.enabled_vendor_interfaces.should have(@num_interfaces -1).things
      @new_valid_project.reload
      @new_valid_project.enabled_vendor_interfaces.should have(@num_interfaces -1).things
    end
    
  end

end
