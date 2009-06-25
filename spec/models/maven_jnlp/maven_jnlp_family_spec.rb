require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MavenJnlp::MavenJnlpFamily do
  before(:each) do
    @valid_attributes = {
      :maven_jnlp_server_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :snapshot_version => "value for snapshot_version",
      :url => "value for url"
    }
  end

  it "should create a new instance given valid attributes" do
    MavenJnlp::MavenJnlpFamily.create!(@valid_attributes)
  end
end
