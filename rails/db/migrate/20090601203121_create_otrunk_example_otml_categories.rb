class CreateOtrunkExampleOtmlCategories < ActiveRecord::Migration
  def self.up
    create_table :otrunk_example_otml_categories do |t|
      t.string :uuid
      t.string :name
      t.timestamps
    end
    add_index :otrunk_example_otml_categories, :name, :unique => true        
  end

  def self.down
    drop_table :otrunk_example_otml_categories
  end
end
