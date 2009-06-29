class CreateAssessmentTargetUnifyingThemes < ActiveRecord::Migration
  def self.up
    create_table :assessment_target_unifying_themes, :id => false do |t|
      t.integer :assessment_target_id
      t.integer :unifying_theme_id
    end
  end

  def self.down
    drop_table :assessment_target_unifying_themes
  end
end
