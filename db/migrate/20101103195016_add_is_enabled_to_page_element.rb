class AddIsEnabledToPageElement < ActiveRecord::Migration
  def self.up
    add_column :page_elements, :is_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :page_elements, :is_enabled
  end
end
