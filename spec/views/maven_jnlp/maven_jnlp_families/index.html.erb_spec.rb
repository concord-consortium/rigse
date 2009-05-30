require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_maven_jnlp_families/index.html.erb" do
  include MavenJnlp::MavenJnlpFamiliesHelper
  
  before(:each) do
    assigns[:maven_jnlp_maven_jnlp_families] = [
      stub_model(MavenJnlp::MavenJnlpFamily,
        :maven_jnlp_server_id => 1,
        :uuid => "value for uuid",
        :name => "value for name",
        :snapshot_version => "value for snapshot_version",
        :url => "value for url"
      ),
      stub_model(MavenJnlp::MavenJnlpFamily,
        :maven_jnlp_server_id => 1,
        :uuid => "value for uuid",
        :name => "value for name",
        :snapshot_version => "value for snapshot_version",
        :url => "value for url"
      )
    ]
  end

  it "renders a list of maven_jnlp_maven_jnlp_families" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for snapshot_version".to_s, 2)
    response.should have_tag("tr>td", "value for url".to_s, 2)
  end
end

