class AddIsEnabledToContainers < ActiveRecord::Migration
  def self.up
    add_column :pages, :is_enabled, :boolean, :default => true
    add_column :sections, :is_enabled, :boolean, :default => true
    add_column :activities, :is_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :activities, :is_enabled
    remove_column :sections, :is_enabled
    remove_column :pages, :is_enabled
  end
end
