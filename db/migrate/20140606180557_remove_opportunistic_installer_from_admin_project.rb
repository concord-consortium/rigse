class RemoveOpportunisticInstallerFromAdminProject < ActiveRecord::Migration
  def self.up
    remove_column :admin_projects, :opportunistic_installer
  end

  def self.down
    add_column :admin_projects, :opportunistic_installer, :boolean, :default => false
  end
end
