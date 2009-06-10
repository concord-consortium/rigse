require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otrunk_imports/edit.html.erb" do
  include OtrunkExample::OtrunkImportsHelper
  
  before(:each) do
    assigns[:otrunk_import] = @otrunk_import = stub_model(OtrunkExample::OtrunkImport,
      :new_record? => false,
      :uuid => "value for uuid",
      :classname => "value for classname",
      :fq_classname => "value for fq_classname"
    )
  end

  it "renders the edit otrunk_import form" do
    render
    
    response.should have_tag("form[action=#{otrunk_import_path(@otrunk_import)}][method=post]") do
      with_tag('input#otrunk_import_uuid[name=?]', "otrunk_import[uuid]")
      with_tag('input#otrunk_import_classname[name=?]', "otrunk_import[classname]")
      with_tag('input#otrunk_import_fq_classname[name=?]', "otrunk_import[fq_classname]")
    end
  end
end


