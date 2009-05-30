require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_maven_jnlp_servers/index.html.erb" do
  include MavenJnlp::MavenJnlpServersHelper
  
  before(:each) do
    assigns[:maven_jnlp_maven_jnlp_servers] = [
      stub_model(MavenJnlp::MavenJnlpServer,
        :uuid => "value for uuid",
        :host => "value for host",
        :path => "value for path",
        :name => "value for name",
        :local_cache_dir => "value for local_cache_dir"
      ),
      stub_model(MavenJnlp::MavenJnlpServer,
        :uuid => "value for uuid",
        :host => "value for host",
        :path => "value for path",
        :name => "value for name",
        :local_cache_dir => "value for local_cache_dir"
      )
    ]
  end

  it "renders a list of maven_jnlp_maven_jnlp_servers" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for host".to_s, 2)
    response.should have_tag("tr>td", "value for path".to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for local_cache_dir".to_s, 2)
  end
end

