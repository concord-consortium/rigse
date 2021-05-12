class AddEnableMemeberRegistrationToAdminProjects < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :enable_member_registration, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :enable_member_registration
  end
end
