class RemoveOpportunisticInstallerFromAdminProject < ActiveRecord::Migration
  def up
    remove_column :admin_projects, :opportunistic_installer
  end

  def down
    add_column :admin_projects, :opportunistic_installer, :boolean, :default => false
  end
end
