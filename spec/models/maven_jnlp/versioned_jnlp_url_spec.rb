require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::VersionedJnlpUrl do
  before(:each) do
    @valid_attributes = {
      :maven_jnlp_family_id => 1,
      :path => "value for path",
      :url => "value for url",
      :version_str => "value for version_str"
    }
  end

  it "should create a new instance given valid attributes" do
    MavenJnlp::VersionedJnlpUrl.create!(@valid_attributes)
  end
end
