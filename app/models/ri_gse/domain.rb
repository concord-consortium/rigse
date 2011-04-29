class RiGse::Domain < ActiveRecord::Base
  set_table_name "ri_gse_domains"

  # belongs_to :user
  has_many :knowledge_statements, :class_name => 'RiGse::KnowledgeStatement'
  acts_as_replicatable
  
  has_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation',
    :finder_sql => 'SELECT ri_gse_grade_span_expectations.* FROM ri_gse_grade_span_expectations
    INNER JOIN ri_gse_assessment_targets ON ri_gse_grade_span_expectations.assessment_target_id = ri_gse_assessment_targets.id 
    INNER JOIN ri_gse_knowledge_statements ON ri_gse_assessment_targets.knowledge_statement_id = ri_gse_knowledge_statements.id 
    WHERE ri_gse_knowledge_statements.domain_id = #{id}'
  
  include Changeable
  
end
