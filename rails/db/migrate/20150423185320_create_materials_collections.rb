class CreateMaterialsCollections < ActiveRecord::Migration
  def change
    create_table :materials_collections do |t|
      t.string :name
      t.text :description
      t.integer :project_id

      t.timestamps
    end

    add_index :materials_collections, :project_id
  end
end
