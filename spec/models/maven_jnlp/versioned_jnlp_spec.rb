require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MavenJnlp::VersionedJnlp do
  before(:each) do
    generate_default_project_and_jnlps_with_factories

    @new_valid_versioned_jnlp = MavenJnlp::VersionedJnlp.new(
      :name => "all-otrunk-snapshot-0.1.0-20090724.190238.jnlp",
      :main_class => "net.sf.sail.emf.launch.EMFLauncher3",
      :href =>  "http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20090724.190238.jnlp",
      :offline_allowed => true,
      :j2se_version => "1.5+",
      :title => "All OTrunk snapshot",
      :max_heap_size => 128,
      :local_resource_signatures_verified => nil,
      :uuid => "09ae2cc0-b3d1-11de-b2b3-001ff3caa767",
      :spec => "1.0+",
      :description => "Preview Basic Pas",
      :initial_heap_size => 32,
      :homepage => "index.html",
      :argument => "dummy",
      :vendor => "Concord Consortium",
      :codebase => "http://jnlp.concord.org/dev",
      :include_pack_gzip => nil
    )
    @new_valid_versioned_jnlp.versioned_jnlp_url = @mock_maven_jnlp_versioned_jnlp_url
    @new_valid_versioned_jnlp.icon = @mock_maven_jnlp_icon
  end

  it "should create a new instance given valid attributes" do
    @new_valid_versioned_jnlp.should be_valid
  end
end
