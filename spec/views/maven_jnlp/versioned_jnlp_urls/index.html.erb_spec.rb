require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_versioned_jnlp_urls/index.html.erb" do
  include MavenJnlp::VersionedJnlpUrlsHelper
  
  before(:each) do
    assigns[:maven_jnlp_versioned_jnlp_urls] = [
      stub_model(MavenJnlp::VersionedJnlpUrl,
        :maven_jnlp_family_id => 1,
        :path => "value for path",
        :url => "value for url",
        :version_str => "value for version_str"
      ),
      stub_model(MavenJnlp::VersionedJnlpUrl,
        :maven_jnlp_family_id => 1,
        :path => "value for path",
        :url => "value for url",
        :version_str => "value for version_str"
      )
    ]
  end

  it "renders a list of maven_jnlp_versioned_jnlp_urls" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for path".to_s, 2)
    response.should have_tag("tr>td", "value for url".to_s, 2)
    response.should have_tag("tr>td", "value for version_str".to_s, 2)
  end
end

