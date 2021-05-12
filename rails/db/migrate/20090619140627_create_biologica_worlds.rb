class CreateBiologicaWorlds < ActiveRecord::Migration[5.1]
  def self.up
    create_table :biologica_worlds do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.text :species_path

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_worlds
  end
end
