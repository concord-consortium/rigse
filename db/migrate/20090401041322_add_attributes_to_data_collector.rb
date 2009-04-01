class AddAttributesToDataCollector < ActiveRecord::Migration
  def self.up
    add_column :data_collectors, :title, :string
    add_column :data_collectors, :x_axis_label, :string
    add_column :data_collectors, :x_axis_units, :string

    add_column :data_collectors, :y_axis_label, :string
    add_column :data_collectors, :y_axis_units, :string

    add_column :data_collectors, :multiple_graphable_enabled, :boolean

    add_column :data_collectors, :draw_marks, :boolean
    add_column :data_collectors, :connect_points, :boolean
    add_column :data_collectors, :autoscale_enabled, :boolean
    add_column :data_collectors, :ruler_enabled, :boolean

    add_column :data_collectors, :show_tare, :boolean
    add_column :data_collectors, :single_value, :boolean    
  end

  def self.down
    remove_column :data_collectors, :title
    remove_column :data_collectors, :x_axis_label
    remove_column :data_collectors, :x_axis_units
    remove
    remove_column :data_collectors, :y_axis_label
    remove_column :data_collectors, :y_axis_units
    remove
    remove_column :data_collectors, :multiple_graphable_enabled
    remove
    remove_column :data_collectors, :draw_marks
    remove_column :data_collectors, :connect_points
    remove_column :data_collectors, :autoscale_enabled
    remove_column :data_collectors, :ruler_enabled
    remove
    remove_column :data_collectors, :show_tare
    remove_column :data_collectors, :single_value    
  end
end
