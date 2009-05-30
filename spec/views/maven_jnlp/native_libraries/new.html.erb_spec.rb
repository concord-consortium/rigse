require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_native_libraries/new.html.erb" do
  include MavenJnlp::NativeLibrariesHelper
  
  before(:each) do
    assigns[:native_library] = stub_model(MavenJnlp::NativeLibrary,
      :new_record? => true,
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

  it "renders new native_library form" do
    render
    
    response.should have_tag("form[action=?][method=post]", maven_jnlp_native_libraries_path) do
      with_tag("input#native_library_uuid[name=?]", "native_library[uuid]")
      with_tag("input#native_library_name[name=?]", "native_library[name]")
      with_tag("input#native_library_main[name=?]", "native_library[main]")
      with_tag("input#native_library_os[name=?]", "native_library[os]")
      with_tag("input#native_library_href[name=?]", "native_library[href]")
      with_tag("input#native_library_size[name=?]", "native_library[size]")
      with_tag("input#native_library_size_pack_gz[name=?]", "native_library[size_pack_gz]")
      with_tag("input#native_library_signature_verified[name=?]", "native_library[signature_verified]")
      with_tag("input#native_library_version_str[name=?]", "native_library[version_str]")
    end
  end
end


