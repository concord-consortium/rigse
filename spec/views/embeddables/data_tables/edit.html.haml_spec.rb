require 'spec_helper'

describe "/embeddable/data_tables/edit.html.haml" do
  include Embeddable::DataTableHelper

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    logout_user
    login_admin
    assigns[:data_table] = @data_table = stub_model(Embeddable::DataTable,
      :new_record? => false, :id => 1, :name => "Data Table", :description => "Desc", :column_count => 4, :visible_rows => 9, :column_names => 'One,Two,Three,Four', :column_data => '', :data_collector_id => nil
    )
  end

  it "renders the edit form" do
    render

    response.should have_tag("form[action=#{embeddable_data_table_path(@data_table)}][method=post]") do
    end
  end

  it "should have a way to select a linked data collector" do
    render
    response.should have_tag("select[name='embeddable_data_table[data_collector_id]']")
  end
end
