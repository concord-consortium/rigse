class AddEnableGradeLevelsToAdminProjects < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :enable_grade_levels, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :enable_grade_levels
  end
end
