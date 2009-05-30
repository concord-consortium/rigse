require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_properties/index.html.erb" do
  include MavenJnlp::PropertiesHelper
  
  before(:each) do
    assigns[:maven_jnlp_properties] = [
      stub_model(MavenJnlp::Property,
        :uuid => "value for uuid",
        :name => "value for name",
        :value => "value for value",
        :os => "value for os"
      ),
      stub_model(MavenJnlp::Property,
        :uuid => "value for uuid",
        :name => "value for name",
        :value => "value for value",
        :os => "value for os"
      )
    ]
  end

  it "renders a list of maven_jnlp_properties" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for value".to_s, 2)
    response.should have_tag("tr>td", "value for os".to_s, 2)
  end
end

