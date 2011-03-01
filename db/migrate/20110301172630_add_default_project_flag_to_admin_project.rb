class AddDefaultProjectFlagToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :default_project, :boolean, :default => true
  end

  def self.down
    remove_column :admin_projects, :default_project
  end
end
