class AddIsPrototypeToEmbeddableDataCollector < ActiveRecord::Migration
  def self.up
    add_column :embeddable_data_collectors, :is_prototype, :boolean, :default => false
    add_index :embeddable_data_collectors, :is_prototype
  end

  def self.down
    remove_index :embeddable_data_collectors, :is_prototype 
    remove_column :embeddable_data_collectors, :is_prototype
  end
end
