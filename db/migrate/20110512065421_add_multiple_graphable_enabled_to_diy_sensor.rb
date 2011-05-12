class AddMultipleGraphableEnabledToDiySensor < ActiveRecord::Migration
  def self.up
    add_column :embeddable_diy_sensors, :multiple_graphable_enabled, :boolean
    add_column :embeddable_diy_sensors, :graph_type, :string
    remove_column :embeddable_diy_sensors, :customizations
  end

  def self.down
    remove_column :embeddable_diy_sensors, :multiple_graphable_enabled
    remove_column :embeddable_diy_sensors, :graph_type
    add_column :embeddable_diy_sensors, :customizations, :text
  end
end
