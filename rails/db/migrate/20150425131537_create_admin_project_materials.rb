class CreateAdminProjectMaterials < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_project_materials do |t|
      t.integer :project_id
      t.integer :material_id
      t.string :material_type

      t.timestamps
    end
  end
end
