require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_maven_jnlp_families/show.html.erb" do
  include MavenJnlp::MavenJnlpFamiliesHelper
  before(:each) do
    assigns[:maven_jnlp_family] = @maven_jnlp_family = stub_model(MavenJnlp::MavenJnlpFamily,
      :maven_jnlp_server_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :snapshot_version => "value for snapshot_version",
      :url => "value for url"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ snapshot_version/)
    response.should have_text(/value\ for\ url/)
  end
end

