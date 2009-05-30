require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_icons/index.html.erb" do
  include MavenJnlp::IconsHelper
  
  before(:each) do
    assigns[:maven_jnlp_icons] = [
      stub_model(MavenJnlp::Icon,
        :uuid => "value for uuid",
        :name => "value for name",
        :href => "value for href",
        :height => 1,
        :width => 1
      ),
      stub_model(MavenJnlp::Icon,
        :uuid => "value for uuid",
        :name => "value for name",
        :href => "value for href",
        :height => 1,
        :width => 1
      )
    ]
  end

  it "renders a list of maven_jnlp_icons" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for href".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end

