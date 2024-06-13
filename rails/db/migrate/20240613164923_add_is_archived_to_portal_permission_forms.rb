class AddIsArchivedToPortalPermissionForms < ActiveRecord::Migration[6.1]
  def change
    add_column :portal_permission_forms, :is_archived, :boolean, default: false, null: false
  end
end
