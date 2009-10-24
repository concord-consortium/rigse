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

end
