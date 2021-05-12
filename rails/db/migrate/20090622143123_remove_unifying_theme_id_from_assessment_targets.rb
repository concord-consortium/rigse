class RemoveUnifyingThemeIdFromAssessmentTargets < ActiveRecord::Migration[5.1]
  def self.up
    remove_column :assessment_targets, :unifying_theme_id
  end

  def self.down
    add_column :assessment_targets, :unifying_theme_id, :integer
  end
end
