require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_maven_jnlp_servers/edit.html.erb" do
  include MavenJnlp::MavenJnlpServersHelper
  
  before(:each) do
    assigns[:maven_jnlp_server] = @maven_jnlp_server = stub_model(MavenJnlp::MavenJnlpServer,
      :new_record? => false,
      :uuid => "value for uuid",
      :host => "value for host",
      :path => "value for path",
      :name => "value for name",
      :local_cache_dir => "value for local_cache_dir"
    )
  end

  it "renders the edit maven_jnlp_server form" do
    render
    
    response.should have_tag("form[action=#{maven_jnlp_server_path(@maven_jnlp_server)}][method=post]") do
      with_tag('input#maven_jnlp_server_uuid[name=?]', "maven_jnlp_server[uuid]")
      with_tag('input#maven_jnlp_server_host[name=?]', "maven_jnlp_server[host]")
      with_tag('input#maven_jnlp_server_path[name=?]', "maven_jnlp_server[path]")
      with_tag('input#maven_jnlp_server_name[name=?]', "maven_jnlp_server[name]")
      with_tag('input#maven_jnlp_server_local_cache_dir[name=?]', "maven_jnlp_server[local_cache_dir]")
    end
  end
end


