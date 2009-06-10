require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otrunk_view_entries/index.html.erb" do
  include OtrunkExample::OtrunkViewEntriesHelper
  
  before(:each) do
    assigns[:otrunk_example_otrunk_view_entries] = [
      stub_model(OtrunkExample::OtrunkViewEntry,
        :uuid => "value for uuid",
        :otml_import_id => 1,
        :classname => "value for classname",
        :fq_classname => "value for fq_classname"
      ),
      stub_model(OtrunkExample::OtrunkViewEntry,
        :uuid => "value for uuid",
        :otml_import_id => 1,
        :classname => "value for classname",
        :fq_classname => "value for fq_classname"
      )
    ]
  end

  it "renders a list of otrunk_example_otrunk_view_entries" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for classname".to_s, 2)
    response.should have_tag("tr>td", "value for fq_classname".to_s, 2)
  end
end

