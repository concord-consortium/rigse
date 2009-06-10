require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otrunk_view_entries/edit.html.erb" do
  include OtrunkExample::OtrunkViewEntriesHelper
  
  before(:each) do
    assigns[:otrunk_view_entry] = @otrunk_view_entry = stub_model(OtrunkExample::OtrunkViewEntry,
      :new_record? => false,
      :uuid => "value for uuid",
      :otml_import_id => 1,
      :classname => "value for classname",
      :fq_classname => "value for fq_classname"
    )
  end

  it "renders the edit otrunk_view_entry form" do
    render
    
    response.should have_tag("form[action=#{otrunk_view_entry_path(@otrunk_view_entry)}][method=post]") do
      with_tag('input#otrunk_view_entry_uuid[name=?]', "otrunk_view_entry[uuid]")
      with_tag('input#otrunk_view_entry_otml_import_id[name=?]', "otrunk_view_entry[otml_import_id]")
      with_tag('input#otrunk_view_entry_classname[name=?]', "otrunk_view_entry[classname]")
      with_tag('input#otrunk_view_entry_fq_classname[name=?]', "otrunk_view_entry[fq_classname]")
    end
  end
end


