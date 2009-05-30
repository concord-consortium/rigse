require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_properties/show.html.erb" do
  include MavenJnlp::PropertiesHelper
  before(:each) do
    assigns[:property] = @property = stub_model(MavenJnlp::Property,
      :uuid => "value for uuid",
      :name => "value for name",
      :value => "value for value",
      :os => "value for os"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ value/)
    response.should have_text(/value\ for\ os/)
  end
end

