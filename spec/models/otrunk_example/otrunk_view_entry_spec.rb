require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OtrunkExample::OtrunkViewEntry do
  before(:each) do
    generate_otrunk_example_with_mocks
    @new_valid_otrunk_view_entry =  OtrunkExample::OtrunkViewEntry.new(
      :classname => "OTDataDrawingToolView",
      :standard_edit_view => false,
      :standard_view => false,
      :fq_classname => "org.concord.datagraph.state.OTDataDrawingToolView",
      :edit_view => false,
      :otrunk_import => @mock_otrunk_import
    )
  end

  it "should create a new instance given valid attributes" do
    @new_valid_otrunk_view_entry.should be_valid
  end
end
