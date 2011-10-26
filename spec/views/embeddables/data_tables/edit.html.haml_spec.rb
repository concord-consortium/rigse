require File.expand_path('../../../../spec_helper', __FILE__)

describe "/embeddable/data_tables/edit.html.haml" do
  include Embeddable::DataTableHelper

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    view.stub!(:edit_menu_for).and_return("edit menu")
    assigns[:data_table] = @data_table = stub_model(Embeddable::DataTable,
      :new_record? => false, :id => 1, :name => "Data Table", :description => "Desc", :column_count => 4, :visible_rows => 9, :column_names => 'One,Two,Three,Four', :column_data => '', :data_collector_id => nil
    )
  end

  it "renders the edit form" do
    render

    response.should have_selector("form[action='#{embeddable_data_table_path(@data_table)}'][method=post]") do
    end
  end

end
