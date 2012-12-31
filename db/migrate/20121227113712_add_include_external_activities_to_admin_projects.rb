class AddIncludeExternalActivitiesToAdminProjects < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :include_external_activities, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :include_external_activities
  end
end
