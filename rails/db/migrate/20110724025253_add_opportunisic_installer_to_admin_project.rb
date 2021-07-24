class AddOpportunisicInstallerToAdminProject < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :opportunistic_installer, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :opportunistic_installer
  end
end
