class AddAttributesToDataCollectors < ActiveRecord::Migration[5.1]
  def self.up
    add_column :data_collectors, :graph_type_id, :integer
    add_column :data_collectors, :prediction_graph_id, :integer
  end

  def self.down
    remove_column :data_collectors, :graph_type_id
    remove_column :data_collectors, :prediction_graph_id
  end
end
