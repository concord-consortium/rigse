require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_jars/index.html.erb" do
  include MavenJnlp::JarsHelper
  
  before(:each) do
    assigns[:maven_jnlp_jars] = [
      stub_model(MavenJnlp::Jar,
        :uuid => "value for uuid",
        :name => "value for name",
        :main => false,
        :os => "value for os",
        :href => "value for href",
        :size => 1,
        :size_pack_gz => 1,
        :signature_verified => false,
        :version_str => "value for version_str"
      ),
      stub_model(MavenJnlp::Jar,
        :uuid => "value for uuid",
        :name => "value for name",
        :main => false,
        :os => "value for os",
        :href => "value for href",
        :size => 1,
        :size_pack_gz => 1,
        :signature_verified => false,
        :version_str => "value for version_str"
      )
    ]
  end

  it "renders a list of maven_jnlp_jars" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", "value for os".to_s, 2)
    response.should have_tag("tr>td", "value for href".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", "value for version_str".to_s, 2)
  end
end

