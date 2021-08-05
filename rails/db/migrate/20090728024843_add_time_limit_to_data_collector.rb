class AddTimeLimitToDataCollector < ActiveRecord::Migration[5.1]
  def self.up
    add_column :data_collectors, :time_limit_status, :boolean, :default => false
    add_column :data_collectors, :time_limit_seconds, :float
  end

  def self.down
    remove_column :data_collectors, :time_limit_status
    remove_column :data_collectors, :time_limit_seconds
  end
end
