class AddDontSanitizeXhtmlToSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_project_settings, :dont_sanitize_xhtml, :boolean
  end

  def self.down
    remove_column :admin_project_settings, :dont_sanitize_xhtml
  end
end
