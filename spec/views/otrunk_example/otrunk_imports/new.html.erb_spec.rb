require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otrunk_imports/new.html.erb" do
  include OtrunkExample::OtrunkImportsHelper
  
  before(:each) do
    assigns[:otrunk_import] = stub_model(OtrunkExample::OtrunkImport,
      :new_record? => true,
      :uuid => "value for uuid",
      :classname => "value for classname",
      :fq_classname => "value for fq_classname"
    )
  end

  it "renders new otrunk_import form" do
    render
    
    response.should have_tag("form[action=?][method=post]", otrunk_example_otrunk_imports_path) do
      with_tag("input#otrunk_import_uuid[name=?]", "otrunk_import[uuid]")
      with_tag("input#otrunk_import_classname[name=?]", "otrunk_import[classname]")
      with_tag("input#otrunk_import_fq_classname[name=?]", "otrunk_import[fq_classname]")
    end
  end
end


