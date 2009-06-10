require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otrunk_imports/show.html.erb" do
  include OtrunkExample::OtrunkImportsHelper
  before(:each) do
    assigns[:otrunk_import] = @otrunk_import = stub_model(OtrunkExample::OtrunkImport,
      :uuid => "value for uuid",
      :classname => "value for classname",
      :fq_classname => "value for fq_classname"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ classname/)
    response.should have_text(/value\ for\ fq_classname/)
  end
end

