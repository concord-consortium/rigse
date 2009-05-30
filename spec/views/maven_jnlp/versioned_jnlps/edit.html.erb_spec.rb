require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_versioned_jnlps/edit.html.erb" do
  include MavenJnlp::VersionedJnlpsHelper
  
  before(:each) do
    assigns[:versioned_jnlp] = @versioned_jnlp = stub_model(MavenJnlp::VersionedJnlp,
      :new_record? => false,
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

  it "renders the edit versioned_jnlp form" do
    render
    
    response.should have_tag("form[action=#{versioned_jnlp_path(@versioned_jnlp)}][method=post]") do
      with_tag('input#versioned_jnlp_maven_jnlp_family_id[name=?]', "versioned_jnlp[maven_jnlp_family_id]")
      with_tag('input#versioned_jnlp_jnlp_icon_id[name=?]', "versioned_jnlp[jnlp_icon_id]")
      with_tag('input#versioned_jnlp_uuid[name=?]', "versioned_jnlp[uuid]")
      with_tag('input#versioned_jnlp_name[name=?]', "versioned_jnlp[name]")
      with_tag('input#versioned_jnlp_main_class[name=?]', "versioned_jnlp[main_class]")
      with_tag('input#versioned_jnlp_argument[name=?]', "versioned_jnlp[argument]")
      with_tag('input#versioned_jnlp_offline_allowed[name=?]', "versioned_jnlp[offline_allowed]")
      with_tag('input#versioned_jnlp_local_resource_signatures_verified[name=?]', "versioned_jnlp[local_resource_signatures_verified]")
      with_tag('input#versioned_jnlp_include_pack_gz[name=?]', "versioned_jnlp[include_pack_gz]")
      with_tag('input#versioned_jnlp_spec[name=?]', "versioned_jnlp[spec]")
      with_tag('input#versioned_jnlp_codebase[name=?]', "versioned_jnlp[codebase]")
      with_tag('input#versioned_jnlp_href[name=?]', "versioned_jnlp[href]")
      with_tag('input#versioned_jnlp_j2se[name=?]', "versioned_jnlp[j2se]")
      with_tag('input#versioned_jnlp_max_heap_size[name=?]', "versioned_jnlp[max_heap_size]")
      with_tag('input#versioned_jnlp_initial_heap_size[name=?]', "versioned_jnlp[initial_heap_size]")
      with_tag('input#versioned_jnlp_title[name=?]', "versioned_jnlp[title]")
      with_tag('input#versioned_jnlp_vendor[name=?]', "versioned_jnlp[vendor]")
      with_tag('input#versioned_jnlp_homepage[name=?]', "versioned_jnlp[homepage]")
      with_tag('input#versioned_jnlp_description[name=?]', "versioned_jnlp[description]")
    end
  end
end


