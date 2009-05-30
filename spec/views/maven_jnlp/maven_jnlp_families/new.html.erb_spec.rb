require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_maven_jnlp_families/new.html.erb" do
  include MavenJnlp::MavenJnlpFamiliesHelper
  
  before(:each) do
    assigns[:maven_jnlp_family] = stub_model(MavenJnlp::MavenJnlpFamily,
      :new_record? => true,
      :maven_jnlp_server_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :snapshot_version => "value for snapshot_version",
      :url => "value for url"
    )
  end

  it "renders new maven_jnlp_family form" do
    render
    
    response.should have_tag("form[action=?][method=post]", maven_jnlp_maven_jnlp_families_path) do
      with_tag("input#maven_jnlp_family_maven_jnlp_server_id[name=?]", "maven_jnlp_family[maven_jnlp_server_id]")
      with_tag("input#maven_jnlp_family_uuid[name=?]", "maven_jnlp_family[uuid]")
      with_tag("input#maven_jnlp_family_name[name=?]", "maven_jnlp_family[name]")
      with_tag("input#maven_jnlp_family_snapshot_version[name=?]", "maven_jnlp_family[snapshot_version]")
      with_tag("input#maven_jnlp_family_url[name=?]", "maven_jnlp_family[url]")
    end
  end
end


