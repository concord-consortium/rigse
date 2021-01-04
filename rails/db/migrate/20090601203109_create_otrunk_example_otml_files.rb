class CreateOtrunkExampleOtmlFiles < ActiveRecord::Migration
  def self.up
    create_table :otrunk_example_otml_files do |t|
      t.string :uuid
      t.integer :otml_category_id
      t.string :name
      t.string :path
      t.text :content
      t.timestamps
    end
    add_index :otrunk_example_otml_files, :otml_category_id    
    add_index :otrunk_example_otml_files, :path, :unique => true    
  end

  def self.down
    drop_table :otrunk_example_otml_files
  end
end
