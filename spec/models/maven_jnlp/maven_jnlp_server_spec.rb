require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::MavenJnlpServer do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :host => "value for host",
      :path => "value for path",
      :name => "value for name",
      :local_cache_dir => "value for local_cache_dir"
    }
  end

  it "should create a new instance given valid attributes" do
    MavenJnlp::MavenJnlpServer.create!(@valid_attributes)
  end

  it "should run update_maven_jnlp_server_object" do
    server = Factory.create(:maven_jnlp_maven_jnlp_server)
    server.update_maven_jnlp_server_object
  end
end
