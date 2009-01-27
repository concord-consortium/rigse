class AssessmentTarget < ActiveRecord::Base
  has_many    :grade_span_expectations
  belongs_to  :knowledge_statement
  belongs_to  :unifying_theme
end
