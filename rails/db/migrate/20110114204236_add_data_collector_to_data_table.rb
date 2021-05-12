class AddDataCollectorToDataTable < ActiveRecord::Migration[5.1]
  def self.up
    add_column :embeddable_data_tables, :data_collector_id, :int
  end

  def self.down
    remove_column :embeddable_data_tables, :data_collector_id
  end
end
