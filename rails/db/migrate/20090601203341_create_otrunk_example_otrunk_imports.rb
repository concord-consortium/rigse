class CreateOtrunkExampleOtrunkImports < ActiveRecord::Migration
  def self.up
    create_table :otrunk_example_otrunk_imports do |t|
      t.string :uuid
      t.string :classname
      t.string :fq_classname
      t.timestamps
    end
    add_index :otrunk_example_otrunk_imports, :fq_classname, :unique => true    
  end

  def self.down
    drop_table :otrunk_example_otrunk_imports
  end
end
