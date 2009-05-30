require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_jars/edit.html.erb" do
  include MavenJnlp::JarsHelper
  
  before(:each) do
    assigns[:jar] = @jar = stub_model(MavenJnlp::Jar,
      :new_record? => false,
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

  it "renders the edit jar form" do
    render
    
    response.should have_tag("form[action=#{jar_path(@jar)}][method=post]") do
      with_tag('input#jar_uuid[name=?]', "jar[uuid]")
      with_tag('input#jar_name[name=?]', "jar[name]")
      with_tag('input#jar_main[name=?]', "jar[main]")
      with_tag('input#jar_os[name=?]', "jar[os]")
      with_tag('input#jar_href[name=?]', "jar[href]")
      with_tag('input#jar_size[name=?]', "jar[size]")
      with_tag('input#jar_size_pack_gz[name=?]', "jar[size_pack_gz]")
      with_tag('input#jar_signature_verified[name=?]', "jar[signature_verified]")
      with_tag('input#jar_version_str[name=?]', "jar[version_str]")
    end
  end
end


