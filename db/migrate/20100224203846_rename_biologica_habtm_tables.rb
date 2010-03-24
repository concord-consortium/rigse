class RenameBiologicaHabtmTables < ActiveRecord::Migration
  def self.up
    rename_table :biologica_chromosome_zooms_biologica_organisms,   :embeddable_biologica_chromosome_zooms_organisms
    rename_table :biologica_multiple_organisms_biologica_organisms, :embeddable_biologica_multiple_organisms_organisms
    rename_table :biologica_organisms_biologica_pedigrees,          :embeddable_biologica_organisms_pedigrees
    
    rename_column :embeddable_biologica_organisms_pedigrees, :biologica_pedigree_id, :pedigree_id
    rename_column :embeddable_biologica_organisms_pedigrees, :biologica_organism_id, :organism_id
    
    rename_column :embeddable_biologica_multiple_organisms_organisms, :biologica_multiple_organism_id, :multiple_organism_id
    rename_column :embeddable_biologica_multiple_organisms_organisms, :biologica_organism_id, :organism_id
    
    rename_column :embeddable_biologica_chromosome_zooms_organisms, :biologica_chromosome_zoom_id, :chromosome_zoom_id
    rename_column :embeddable_biologica_chromosome_zooms_organisms, :biologica_organism_id, :organism_id
  end

  def self.down
    rename_column :embeddable_biologica_chromosome_zooms_organisms, :organism_id, :biologica_organism_id
    rename_column :embeddable_biologica_chromosome_zooms_organisms, :chromosome_zoom_id, :biologica_chromosome_zoom_id
    
    rename_column :embeddable_biologica_multiple_organisms_organisms, :organism_id, :biologica_organism_id
    rename_column :embeddable_biologica_multiple_organisms_organisms, :multiple_organism_id, :biologica_multiple_organism_id
    
    rename_column :embeddable_biologica_organisms_pedigrees, :organism_id, :biologica_organism_id
    rename_column :embeddable_biologica_organisms_pedigrees, :pedigree_id, :biologica_pedigree_id
    
    rename_table :embeddable_biologica_organisms_pedigrees,          :biologica_organisms_biologica_pedigrees
    rename_table :embeddable_biologica_multiple_organisms_organisms, :biologica_multiple_organisms_biologica_organisms
    rename_table :embeddable_biologica_chromosome_zooms_organisms,   :biologica_chromosome_zooms_biologica_organisms
  end
end
