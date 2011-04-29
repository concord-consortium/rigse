class RiGse::AssessmentTarget < ActiveRecord::Base
  set_table_name "ri_gse_assessment_targets"

  
  # belongs_to :user
  belongs_to :knowledge_statement, :class_name => 'RiGse::KnowledgeStatement'
  has_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation'
  has_many :assessment_target_unifying_themes, :class_name => 'RiGse::AssessmentTargetUnifyingTheme'
  has_and_belongs_to_many :unifying_themes, :class_name => 'RiGse::UnifyingTheme', :join_table => :ri_gse_assessment_target_unifying_themes

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
