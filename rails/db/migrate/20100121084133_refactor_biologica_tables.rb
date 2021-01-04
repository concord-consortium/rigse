class RefactorBiologicaTables < ActiveRecord::Migration
  def self.up
    rename_column :embeddable_biologica_chromosomes, :biologica_organism_id, :organism_id
    rename_column :embeddable_biologica_organisms, :biologica_world_id, :world_id
    rename_column :embeddable_biologica_static_organisms, :biologica_organism_id, :organism_id
  end

  def self.down
    rename_column :embeddable_biologica_chromosomes, :organism_id, :biologica_organism_id
    rename_column :embeddable_biologica_organisms, :world_id, :biologica_world_id
    rename_column :embeddable_biologica_static_organisms, :organism_id, :biologica_organism_id
  end
end
