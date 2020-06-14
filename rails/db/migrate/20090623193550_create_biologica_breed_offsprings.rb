class CreateBiologicaBreedOffsprings < ActiveRecord::Migration
  def self.up
    create_table :biologica_breed_offsprings do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :width
      t.integer :height
      t.integer :mother_organism_id
      t.integer :father_organism_id

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_breed_offsprings
  end
end
