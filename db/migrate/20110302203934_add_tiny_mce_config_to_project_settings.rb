class AddTinyMceConfigToProjectSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_project_settings, :tiny_mce_config, :text
  end

  def self.down
    remove_column :admin_project_settings, :tiny_mce_config
  end
end
