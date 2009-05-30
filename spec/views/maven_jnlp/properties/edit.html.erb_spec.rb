require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_properties/edit.html.erb" do
  include MavenJnlp::PropertiesHelper
  
  before(:each) do
    assigns[:property] = @property = stub_model(MavenJnlp::Property,
      :new_record? => false,
      :uuid => "value for uuid",
      :name => "value for name",
      :value => "value for value",
      :os => "value for os"
    )
  end

  it "renders the edit property form" do
    render
    
    response.should have_tag("form[action=#{property_path(@property)}][method=post]") do
      with_tag('input#property_uuid[name=?]', "property[uuid]")
      with_tag('input#property_name[name=?]', "property[name]")
      with_tag('input#property_value[name=?]', "property[value]")
      with_tag('input#property_os[name=?]', "property[os]")
    end
  end
end


