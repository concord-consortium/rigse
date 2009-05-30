require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_maven_jnlp_servers/show.html.erb" do
  include MavenJnlp::MavenJnlpServersHelper
  before(:each) do
    assigns[:maven_jnlp_server] = @maven_jnlp_server = stub_model(MavenJnlp::MavenJnlpServer,
      :uuid => "value for uuid",
      :host => "value for host",
      :path => "value for path",
      :name => "value for name",
      :local_cache_dir => "value for local_cache_dir"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ host/)
    response.should have_text(/value\ for\ path/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ local_cache_dir/)
  end
end

