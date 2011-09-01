require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::NativeLibrary do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :name => "value for name",
      :main => false,
      :os => "value for os",
      :href => "value for href",
      :size => 1,
      :size_pack_gz => 1,
      :signature_verified => false,
      :version_str => "value for version_str"
    }
  end

  it "should create a new instance given valid attributes" do
    MavenJnlp::NativeLibrary.create!(@valid_attributes)
  end
end
