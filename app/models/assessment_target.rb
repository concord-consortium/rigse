class AssessmentTarget < ActiveRecord::Base
  belongs_to :user
  has_many    :grade_span_expectations
  belongs_to  :knowledge_statement
  belongs_to  :unifying_theme
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
