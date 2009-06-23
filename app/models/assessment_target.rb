class AssessmentTarget < ActiveRecord::Base
  
  # belongs_to :user
  belongs_to :knowledge_statement
  has_many :grade_span_expectations
  has_many :assessment_target_unifying_themes
  has_many :unifying_themes, :through => :assessment_target_unifying_themes

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
