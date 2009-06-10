require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otrunk_view_entries/show.html.erb" do
  include OtrunkExample::OtrunkViewEntriesHelper
  before(:each) do
    assigns[:otrunk_view_entry] = @otrunk_view_entry = stub_model(OtrunkExample::OtrunkViewEntry,
      :uuid => "value for uuid",
      :otml_import_id => 1,
      :classname => "value for classname",
      :fq_classname => "value for fq_classname"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ classname/)
    response.should have_text(/value\ for\ fq_classname/)
  end
end

