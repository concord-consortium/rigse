class RiGse::BigIdea < ActiveRecord::Base
  self.table_name = "ri_gse_big_ideas"

  # belongs_to :user
  belongs_to :unifying_theme, :class_name => 'RiGse::UnifyingTheme'
  has_many :assessment_targets, :class_name => 'RiGse::AssessmentTarget', :through => :unifying_theme
  
  acts_as_replicatable
  
  include Changeable
  
end
