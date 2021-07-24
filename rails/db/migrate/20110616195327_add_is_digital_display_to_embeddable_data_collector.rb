class AddIsDigitalDisplayToEmbeddableDataCollector < ActiveRecord::Migration[5.1]
  def self.up
    add_column :embeddable_data_collectors, :is_digital_display, :boolean, :default => 0
  end

  def self.down
    remove_column :embeddable_data_collectors, :is_digital_display
  end
end
