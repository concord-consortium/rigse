class CreateBiologicaMeiosisViews < ActiveRecord::Migration
  def self.up
    create_table :biologica_meiosis_views do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :width
      t.integer :height
      t.boolean :replay_button_enabled
      t.boolean :controlled_crossover_enabled
      t.boolean :crossover_control_visible
      t.boolean :controlled_alignment_enabled
      t.boolean :alignment_control_visible
      t.integer :father_organism_id
      t.integer :mother_organism_id

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_meiosis_views
  end
end
