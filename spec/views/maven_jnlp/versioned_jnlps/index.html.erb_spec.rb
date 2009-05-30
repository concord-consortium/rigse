require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_versioned_jnlps/index.html.erb" do
  include MavenJnlp::VersionedJnlpsHelper
  
  before(:each) do
    assigns[:maven_jnlp_versioned_jnlps] = [
      stub_model(MavenJnlp::VersionedJnlp,
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
      ),
      stub_model(MavenJnlp::VersionedJnlp,
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
    ]
  end

  it "renders a list of maven_jnlp_versioned_jnlps" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for main_class".to_s, 2)
    response.should have_tag("tr>td", "value for argument".to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", "value for spec".to_s, 2)
    response.should have_tag("tr>td", "value for codebase".to_s, 2)
    response.should have_tag("tr>td", "value for href".to_s, 2)
    response.should have_tag("tr>td", "value for j2se".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for title".to_s, 2)
    response.should have_tag("tr>td", "value for vendor".to_s, 2)
    response.should have_tag("tr>td", "value for homepage".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
  end
end

