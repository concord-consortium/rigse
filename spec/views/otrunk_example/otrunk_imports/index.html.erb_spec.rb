require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otrunk_imports/index.html.erb" do
  include OtrunkExample::OtrunkImportsHelper
  
  before(:each) do
    assigns[:otrunk_example_otrunk_imports] = [
      stub_model(OtrunkExample::OtrunkImport,
        :uuid => "value for uuid",
        :classname => "value for classname",
        :fq_classname => "value for fq_classname"
      ),
      stub_model(OtrunkExample::OtrunkImport,
        :uuid => "value for uuid",
        :classname => "value for classname",
        :fq_classname => "value for fq_classname"
      )
    ]
  end

  it "renders a list of otrunk_example_otrunk_imports" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for classname".to_s, 2)
    response.should have_tag("tr>td", "value for fq_classname".to_s, 2)
  end
end

