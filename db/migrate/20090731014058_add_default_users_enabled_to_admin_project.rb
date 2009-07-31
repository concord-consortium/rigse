class AddDefaultUsersEnabledToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :enable_default_users, :boolean
  end

  def self.down
    remove_column :admin_projects, :enable_default_users
  end
end
