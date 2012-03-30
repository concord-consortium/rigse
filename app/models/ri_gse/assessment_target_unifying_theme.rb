class RiGse::AssessmentTargetUnifyingTheme < ActiveRecord::Base
  self.table_name = "ri_gse_assessment_target_unifying_themes"

  belongs_to :assessment_target, :class_name => 'RiGse::AssessmentTarget'
  belongs_to :unifying_theme, :class_name => 'RiGse::UnifyingTheme'
end
