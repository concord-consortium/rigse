class CreateBiologicaMultipleOrganisms < ActiveRecord::Migration
  def self.up
    create_table :biologica_multiple_organisms do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :width
      t.integer :height
      t.integer :organism_image_size

      t.timestamps
    end
    
    create_table :biologica_multiple_organisms_biologica_organisms, :id => false do |t|
      t.integer :biologica_multiple_organism_id
      t.integer :biologica_organism_id

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_multiple_organisms
    drop_table :biologica_multiple_organisms_biologica_organisms
  end
end
