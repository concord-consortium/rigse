class CreateMaterialsCollectionItems < ActiveRecord::Migration
  def change
    create_table :materials_collection_items do |t|
      t.integer :materials_collection_id
      t.string  :material_type
      t.integer :material_id
      t.integer :position

      t.timestamps
    end

    add_index :materials_collection_items, [:material_id, :material_type, :position], name: 'material_idx'
    add_index :materials_collection_items, [:materials_collection_id, :position], name: 'materials_collection_idx'
  end
end
