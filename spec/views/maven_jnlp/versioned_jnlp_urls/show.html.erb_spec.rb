require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_versioned_jnlp_urls/show.html.erb" do
  include MavenJnlp::VersionedJnlpUrlsHelper
  before(:each) do
    assigns[:versioned_jnlp_url] = @versioned_jnlp_url = stub_model(MavenJnlp::VersionedJnlpUrl,
      :maven_jnlp_family_id => 1,
      :path => "value for path",
      :url => "value for url",
      :version_str => "value for version_str"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/value\ for\ path/)
    response.should have_text(/value\ for\ url/)
    response.should have_text(/value\ for\ version_str/)
  end
end

