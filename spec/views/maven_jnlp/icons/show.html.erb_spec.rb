require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_icons/show.html.erb" do
  include MavenJnlp::IconsHelper
  before(:each) do
    assigns[:icon] = @icon = stub_model(MavenJnlp::Icon,
      :uuid => "value for uuid",
      :name => "value for name",
      :href => "value for href",
      :height => 1,
      :width => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ href/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end

