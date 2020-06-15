class CreateBiologicaOrganisms < ActiveRecord::Migration
  def self.up
    create_table :biologica_organisms do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :sex
      t.string :alleles
      t.string :strain
      t.integer :chromosomes_color
      t.boolean :fatal_characteristics
      t.integer :biologica_world_id

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_organisms
  end
end
