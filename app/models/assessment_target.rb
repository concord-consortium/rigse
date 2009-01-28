class AssessmentTarget < ActiveRecord::Base
  belongs_to :user
  has_many    :grade_span_expectations
  belongs_to  :knowledge_statement
  belongs_to  :unifying_theme
  acts_as_replicatable
end
