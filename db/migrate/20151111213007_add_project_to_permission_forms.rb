class AddProjectToPermissionForms < ActiveRecord::Migration
  def change
    add_column :portal_permission_forms, :project_id, :integer
  end
end
