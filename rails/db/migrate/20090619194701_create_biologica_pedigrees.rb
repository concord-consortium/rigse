class CreateBiologicaPedigrees < ActiveRecord::Migration
  def self.up
    create_table :biologica_pedigrees do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :height
      t.integer :width
      t.boolean :crossover_enabled
      t.boolean :sex_text_visible
      t.boolean :organism_images_visible
      t.boolean :top_controls_visible
      t.boolean :reset_button_visible
      t.integer :organism_image_size
      t.integer :minimum_number_children
      t.integer :maximum_number_children

      t.timestamps
    end
    
    create_table :biologica_organisms_biologica_pedigrees, :id => false do |t|
      t.integer :biologica_pedigree_id
      t.integer :biologica_organism_id

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_pedigrees
    drop_table :biologica_organisms_biologica_pedigrees
  end
end
