class RiGse::UnifyingTheme < ActiveRecord::Base
  set_table_name "ri_gse_unifying_themes"

  # belongs_to :user
  has_many :big_ideas, :class_name => 'RiGse::BigIdea'
  has_many :assessment_target_unifying_themes, :class_name => 'RiGse::AssessmentTargetUnifyingTheme'
  has_and_belongs_to_many :assessment_targets, :class_name => 'RiGse::AssessmentTarget', :join_table => :ri_gse_assessment_target_unifying_themes
  has_many :knowledge_statements, :class_name => 'RiGse::KnowledgeStatement', :through => :assessment_targets
  has_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation', :through => :assessment_targets
  
  acts_as_replicatable
  
  include Changeable
  
end
