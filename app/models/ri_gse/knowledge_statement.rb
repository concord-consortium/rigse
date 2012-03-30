class RiGse::KnowledgeStatement < ActiveRecord::Base
  self.table_name = "ri_gse_knowledge_statements"

  # belongs_to :user
  belongs_to :domain, :class_name => 'RiGse::Domain'
  has_many :assessment_targets, :class_name => 'RiGse::AssessmentTarget'
  has_many :unifying_themes, :class_name => 'RiGse::UnifyingTheme', :through => :assessment_targets
  has_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation', :through => :assessment_targets

  acts_as_replicatable

  include Changeable

end
