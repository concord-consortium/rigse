class CreateOtrunkExampleOtrunkViewEntries < ActiveRecord::Migration
  def self.up
    create_table :otrunk_example_otrunk_view_entries do |t|
      t.string :uuid
      t.integer :otrunk_import_id
      t.string :classname
      t.string :fq_classname
      t.boolean :standard_view
      t.boolean :standard_edit_view
      t.boolean :edit_view
      t.timestamps
    end
    add_index :otrunk_example_otrunk_view_entries, :fq_classname, :unique => true    
  end

  def self.down
    drop_table :otrunk_example_otrunk_view_entries
  end
end
