require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::Project do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :url => "value for url",
      :states_and_provinces => "value for states_and_provinces",
      :maven_jnlp_server_id => 1,
      :maven_jnlp_family_id => 1,
      :jnlp_version => "value for jnlp_version",
      :snapshot_enabled => false
    }
  end

  it "should create a new instance given valid attributes" do
    Admin::Project.create!(@valid_attributes)
  end
end
