require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_versioned_jnlps/show.html.erb" do
  include MavenJnlp::VersionedJnlpsHelper
  before(:each) do
    assigns[:versioned_jnlp] = @versioned_jnlp = stub_model(MavenJnlp::VersionedJnlp,
      :maven_jnlp_family_id => 1,
      :jnlp_icon_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :main_class => "value for main_class",
      :argument => "value for argument",
      :offline_allowed => false,
      :local_resource_signatures_verified => false,
      :include_pack_gz => false,
      :spec => "value for spec",
      :codebase => "value for codebase",
      :href => "value for href",
      :j2se => "value for j2se",
      :max_heap_size => 1,
      :initial_heap_size => 1,
      :title => "value for title",
      :vendor => "value for vendor",
      :homepage => "value for homepage",
      :description => "value for description"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ main_class/)
    response.should have_text(/value\ for\ argument/)
    response.should have_text(/false/)
    response.should have_text(/false/)
    response.should have_text(/false/)
    response.should have_text(/value\ for\ spec/)
    response.should have_text(/value\ for\ codebase/)
    response.should have_text(/value\ for\ href/)
    response.should have_text(/value\ for\ j2se/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ title/)
    response.should have_text(/value\ for\ vendor/)
    response.should have_text(/value\ for\ homepage/)
    response.should have_text(/value\ for\ description/)
  end
end

