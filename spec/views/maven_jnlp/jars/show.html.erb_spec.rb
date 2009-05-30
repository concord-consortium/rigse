require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_jars/show.html.erb" do
  include MavenJnlp::JarsHelper
  before(:each) do
    assigns[:jar] = @jar = stub_model(MavenJnlp::Jar,
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
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/false/)
    response.should have_text(/value\ for\ os/)
    response.should have_text(/value\ for\ href/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/false/)
    response.should have_text(/value\ for\ version_str/)
  end
end

