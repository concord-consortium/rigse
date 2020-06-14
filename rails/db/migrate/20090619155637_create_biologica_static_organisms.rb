class CreateBiologicaStaticOrganisms < ActiveRecord::Migration
  def self.up
    create_table :biologica_static_organisms do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :biologica_organism_id

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_static_organisms
  end
end
