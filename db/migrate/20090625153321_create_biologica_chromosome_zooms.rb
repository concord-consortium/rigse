class CreateBiologicaChromosomeZooms < ActiveRecord::Migration
  def self.up
    create_table :biologica_chromosome_zooms do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.boolean :chromosome_a_visible
      t.boolean :chromosome_b_visible
      t.integer :chromosome_position_in_base_pairs
      t.float :chromosome_position_in_cm
      t.boolean :draw_crossover
      t.boolean :draw_genes
      t.boolean :draw_markers
      t.boolean :draw_tracks
      t.string :g_browse_url_template
      t.boolean :image_label_characteristics_text_visible
      t.boolean :image_label_lock_symbol_visible
      t.boolean :image_label_name_text_visible
      t.boolean :image_label_sex_text_visible
      t.integer :image_label_size
      t.boolean :image_label_species_text_visible
      t.integer :organism_label_type
      t.integer :zoom_level

      t.timestamps
    end
    
    create_table :biologica_chromosome_zooms_biologica_organisms, :id => false do |t|
      t.integer :biologica_chromosome_zoom_id
      t.integer :biologica_organism_id

      t.timestamps
    end
  end

  def self.down
    drop_table :biologica_chromosome_zooms
    drop_table :biologica_chromosome_zooms_biologica_organisms
  end
end
