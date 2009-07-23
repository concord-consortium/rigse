class AssessmentTarget < ActiveRecord::Base
  
  # belongs_to :user
  belongs_to :knowledge_statement
  has_many :grade_span_expectations
  has_many :assessment_target_unifying_themes
  has_and_belongs_to_many :unifying_themes, :join_table => :assessment_target_unifying_themes

  acts_as_replicatable

  include Changeable

  self.extend SearchableModel

  @@searchable_attributes = %w{description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  def add_unifying_theme(theme)
    self.unifying_themes << theme unless has_unifying_theme?(theme)
  end 
  
  def has_unifying_theme?(theme)
    (self.unifying_themes.collect { |t| t.id }).include?(theme.id)
  end
   
end
