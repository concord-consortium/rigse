class AddPredictionToSensor < ActiveRecord::Migration
  def self.up
    add_column :embeddable_diy_sensors, :prediction_graph_id, :integer
    add_index  :embeddable_diy_sensors, :prediction_graph_id 
  end

  def self.down
    remove_index :embeddable_diy_sensors, :column => :prediction_graph_id
    remove_column :embeddable_diy_sensors, :prediction_graph_id
  end
end
