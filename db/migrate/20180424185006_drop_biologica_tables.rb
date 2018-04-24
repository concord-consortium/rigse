class DropBiologicaTables < ActiveRecord::Migration
  def remove_table(name)
    drop_table name.to_sym if ActiveRecord::Base.connection.tables.include?(name)
  end

  def up
    [
      "embeddable_biologica_breed_offsprings",
      "embeddable_biologica_chromosome_zooms",
      "embeddable_biologica_chromosome_zooms_organisms",
      "embeddable_biologica_chromosomes",
      "embeddable_biologica_meiosis_views",
      "embeddable_biologica_multiple_organisms",
      "embeddable_biologica_multiple_organisms_organisms",
      "embeddable_biologica_organisms",
      "embeddable_biologica_organisms_pedigrees",
      "embeddable_biologica_pedigrees",
      "embeddable_biologica_static_organisms",
      "embeddable_biologica_worlds"
    ].each { |table| self.remove_table(table) }
    execute "delete from saveable_external_links where embeddable_type like '%Biologica%'"
    execute "delete from page_elements where embeddable_type like '%Biologica%'"
    execute "delete from portal_offering_embeddable_metadata where embeddable_type like '%Biologica%'"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
