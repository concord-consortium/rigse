class Domain < ActiveRecord::Base
  # belongs_to :user
  has_many :knowledge_statements
  acts_as_replicatable
  
  has_many :grade_span_expectations,
    :finder_sql => 'SELECT grade_span_expectations.* FROM grade_span_expectations
    INNER JOIN assessment_targets ON grade_span_expectations.assessment_target_id = assessment_targets.id 
    INNER JOIN knowledge_statements ON assessment_targets.knowledge_statement_id = knowledge_statements.id 
    WHERE  knowledge_statements.domain_id = #{id}'
  
  include Changeable
  
end
