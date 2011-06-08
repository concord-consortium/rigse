require File.expand_path('../../../../spec_helper', __FILE__)

describe "/embeddable/data_collectors/edit.html.haml" do
  include Embeddable::DataCollectorHelper

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    power_user = stub_model(User, :has_role? => true)
    template.stub!(:edit_menu_for).and_return("edit menu")
    template.stub!(:current_user).and_return(power_user)
    assigns[:scope] = mock(
      :id => 1, 
      :activity => mock (
        :data_collectors => [],
        :data_tables => []
    ))
    assigns[:data_collector] = @data_collector = stub_model(Embeddable::DataCollector,
      :new_record? => false, 
      :id => 1, 
      :name => "Data Collector",
      :time_limit_seconds =>nil, 
      :prediction_graph_id =>nil, 
      :data_store_values =>nil, 
      :title =>"Data Graph", 
      :draw_marks => false, 
      :connect_points =>true, 
      :y_axis_max => 5,
      :uuid => "42e1cb70-87cc-11e0-a372-0023df83af94",
      :data_table_id =>nil, 
      :x_axis_max =>30, 
      :show_tare =>false, 
      :ruler_enabled =>false, 
      :y_axis_units =>nil,
      :static => nil,
      :id =>3425, 
      :y_axis_min =>0, 
      :y_axis_label =>"Temperature", 
      :x_axis_units =>"s", 
      :otml_library_content =>nil, 
      :graph_type_id => 1, 
      :x_axis_min =>0, 
      :x_axis_label =>"Time", 
      :autoscale_enabled =>false, 
      :time_limit_status =>false, 
      :single_value =>false, 
      :probe_type_id =>1, 
      :multiple_graphable_enabled =>false, 
      :calibration_id =>nil,
      :user => power_user)
  end

  it "renders the edit form" do
    render
    response.should have_tag("form[action=#{embeddable_data_collector_path(@data_collector)}][method=post]") do
    end
  end

  it "should have a way to select a linked data collector" do
    render
    response.should have_tag("select[name='embeddable_data_collector[data_table_id]']")
  end
end
