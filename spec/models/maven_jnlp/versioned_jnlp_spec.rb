require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MavenJnlp::VersionedJnlp do
  before(:each) do
    @valid_attributes = {
      :versioned_jnlp_url_id => 1,
      :jnlp_icon_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :main_class => "value for main_class",
      :argument => "value for argument",
      :offline_allowed => false,
      :local_resource_signatures_verified => false,
      :include_pack_gzip => false,
      :spec => "value for spec",
      :codebase => "value for codebase",
      :href => "value for href",
      :j2se_version => "value for j2se",
      :max_heap_size => 1,
      :initial_heap_size => 1,
      :title => "value for title",
      :vendor => "value for vendor",
      :homepage => "value for homepage",
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    MavenJnlp::VersionedJnlp.create!(@valid_attributes)
  end
end
