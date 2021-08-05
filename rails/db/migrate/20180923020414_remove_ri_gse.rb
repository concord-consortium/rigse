class RemoveRiGse < ActiveRecord::Migration[5.1]
  def remove_table(name)
    drop_table name.to_sym if ApplicationRecord.connection.tables.include?(name)
  end

  def up
    [
      "ri_gse_assessment_target_unifying_themes",
      "ri_gse_assessment_targets",
      "ri_gse_big_ideas",
      "ri_gse_domains",
      "ri_gse_expectation_indicators",
      "ri_gse_expectation_stems",
      "ri_gse_expectations",
      "ri_gse_grade_span_expectations",
      "ri_gse_knowledge_statements",
      "ri_gse_unifying_themes"
    ].each{|t| remove_table(t)}

    remove_column :portal_teachers, :domain_id
    remove_column :investigations, :grade_span_expectation_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
