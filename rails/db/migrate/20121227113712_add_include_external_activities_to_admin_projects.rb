class AddIncludeExternalActivitiesToAdminProjects < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :include_external_activities, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :include_external_activities
  end
end
