class OtmlFilesOtrunkImports < ActiveRecord::Migration
  def self.up
    create_table :otml_files_otrunk_imports, :id => false do |t|
      t.integer :otml_file_id
      t.integer :otrunk_import_id
    end
    add_index :otml_files_otrunk_imports, [:otml_file_id, :otrunk_import_id], :name => :otf_oti, :unique => true
  end

  def self.down
    drop_table :otml_files_otrunk_imports
  end
end
