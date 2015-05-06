class AddIndexesToAdminProjectMaterials < ActiveRecord::Migration
  def change
    add_index :admin_project_materials, :project_id, name: 'admin_proj_mat_proj_idx'
    add_index :admin_project_materials, [:material_id, :material_type], name: 'admin_proj_mat_mat_idx'
    add_index :admin_project_materials, [:project_id, :material_id, :material_type], name: 'admin_proj_mat_proj_mat_idx'
  end
end
