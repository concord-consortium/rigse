class CreateBiologicaChromosomes < ActiveRecord::Migration
  def self.up
    create_table :biologica_chromosomes do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :biologica_organism_id
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_chromosomes
  end
end
