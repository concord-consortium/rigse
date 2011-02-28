class RemoveActiveGradesAssociationFromProjectSettings < ActiveRecord::Migration
  def self.up
    drop_table :admin_project_settings_portal_grade_levels
    add_column :admin_project_settings, :active_grades, :text
  end

  def self.down
    remove_column :admin_project_settings, :active_grades
    create_table :admin_project_settings_portal_grade_levels do |t|
      t.references :admin_project_settings
      t.references :portal_grade_level
    end
  end
end
