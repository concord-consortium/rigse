class OtmlFilesOtrunkViewEntries < ActiveRecord::Migration
  def self.up
    create_table :otml_files_otrunk_view_entries, :id => false do |t|
      t.integer :otml_file_id
      t.integer :otrunk_view_entry_id
    end
    add_index :otml_files_otrunk_view_entries, [:otml_file_id, :otrunk_view_entry_id], :name => :otf_otve, :unique => true
  end

  def self.down
    drop_table :otml_files_otrunk_view_entries
  end
end
