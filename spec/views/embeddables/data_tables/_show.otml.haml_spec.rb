require 'spec_helper'

describe "/embeddable/data_tables/_show.otml.haml" do
  include Embeddable::DataTableHelper
  include ApplicationHelper

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    template.stub!(:edit_menu_for).and_return("edit menu")
    assigns[:data_table] = @data_table = stub_model(Embeddable::DataTable,
      :new_record? => false, :id => 1, :name => "Data Table", :description => "Desc", :column_count => 4, :visible_rows => 9, :column_names => 'One,Two,Three,Four', :column_data => '', :data_collector_id => nil
    )
  end

  it "renders the OTDataTable" do
    render :locals => { :data_table => @data_table }
    response.should have_tag("OTDataTable[local_id=?][name=?][visibleRows=?]", 'data_table_1', 'Data Table', '9') do
      with_tag("dataStore") do
        with_tag("OTDataStore[numberChannels=?]",'4')
        with_tag("channelDescriptions") do
          with_tag("OTDataChannelDescription[name=?]","One")
          with_tag("OTDataChannelDescription[name=?]","Two")
          with_tag("OTDataChannelDescription[name=?]","Three")
          with_tag("OTDataChannelDescription[name=?]","Four")
        end
      end
    end
  end
end
