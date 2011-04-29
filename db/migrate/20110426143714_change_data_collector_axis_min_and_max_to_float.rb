class ChangeDataCollectorAxisMinAndMaxToFloat < ActiveRecord::Migration
  def self.up
    change_column :embeddable_data_collectors, :x_axis_min, :float, :default =>  0.0
    change_column :embeddable_data_collectors, :y_axis_min, :float, :default =>  0.0
    change_column :embeddable_data_collectors, :x_axis_max, :float, :default => 60.0
    change_column :embeddable_data_collectors, :y_axis_max, :float, :default =>  5.0
  end

  def self.down
    change_column :embeddable_data_collectors, :x_axis_min, :integer, :default =>  0
    change_column :embeddable_data_collectors, :y_axis_min, :integer, :default =>  0
    change_column :embeddable_data_collectors, :x_axis_max, :integer, :default => 60
    change_column :embeddable_data_collectors, :y_axis_max, :integer, :default =>  5
  end
end
