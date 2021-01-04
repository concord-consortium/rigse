class OtmlCategoriesOtrunkImports < ActiveRecord::Migration
  def self.up
    create_table :otml_categories_otrunk_imports, :id => false do |t|
      t.integer :otml_category_id
      t.integer :otrunk_import_id
    end
    add_index :otml_categories_otrunk_imports, [:otml_category_id, :otrunk_import_id], :name => :otc_oti, :unique => true
  end

  def self.down
    drop_table :otml_categories_otrunk_imports
  end
end
