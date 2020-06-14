class ChangeGseFieldTypes < ActiveRecord::Migration
  def self.up
    [ :ri_gse_assessment_targets, 
      :ri_gse_big_ideas, 
      :ri_gse_expectation_indicators,
      :ri_gse_expectation_stems, 
      :ri_gse_knowledge_statements].each do |table|
       change_column(table, :description, :text)
     end
  end

  def self.down
    [ :ri_gse_assessment_targets, 
      :ri_gse_big_ideas, 
      :ri_gse_expectation_indicators,
      :ri_gse_expectation_stems, 
      :ri_gse_knowledge_statements].each do |table|
       change_column(table, :description, :string)
     end
  end
end
