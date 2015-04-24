class RenameAdminProjectToAdminSettings < ActiveRecord::Migration
  def change
    rename_table :admin_projects, :admin_settings

    rename_table :admin_project_vendor_interfaces, :admin_settings_vendor_interfaces
    rename_column :admin_settings_vendor_interfaces, :admin_project_id, :admin_settings_id
  end
end
