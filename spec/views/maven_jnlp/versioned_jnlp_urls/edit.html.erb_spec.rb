require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_versioned_jnlp_urls/edit.html.erb" do
  include MavenJnlp::VersionedJnlpUrlsHelper
  
  before(:each) do
    assigns[:versioned_jnlp_url] = @versioned_jnlp_url = stub_model(MavenJnlp::VersionedJnlpUrl,
      :new_record? => false,
      :maven_jnlp_family_id => 1,
      :path => "value for path",
      :url => "value for url",
      :version_str => "value for version_str"
    )
  end

  it "renders the edit versioned_jnlp_url form" do
    render
    
    response.should have_tag("form[action=#{versioned_jnlp_url_path(@versioned_jnlp_url)}][method=post]") do
      with_tag('input#versioned_jnlp_url_maven_jnlp_family_id[name=?]', "versioned_jnlp_url[maven_jnlp_family_id]")
      with_tag('input#versioned_jnlp_url_path[name=?]', "versioned_jnlp_url[path]")
      with_tag('input#versioned_jnlp_url_url[name=?]', "versioned_jnlp_url[url]")
      with_tag('input#versioned_jnlp_url_version_str[name=?]', "versioned_jnlp_url[version_str]")
    end
  end
end


