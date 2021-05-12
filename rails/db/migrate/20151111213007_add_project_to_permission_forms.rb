class AddProjectToPermissionForms < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_permission_forms, :project_id, :integer
  end
end
