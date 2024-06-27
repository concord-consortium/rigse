class AddCanManagePermissionFormsToAdminProjectUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_project_users, :can_manage_permission_forms, :boolean, default: false, null: false
  end
end
