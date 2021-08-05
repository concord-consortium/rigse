class AddDefaultUserAndSiteAdminToUsers < ActiveRecord::Migration[5.1]
  def self.up
    add_column :users, :default_user, :boolean, :default => false
    add_column :users, :site_admin, :boolean, :default => false
  end

  def self.down
    remove_column :users, :default_user
    remove_column :users, :site_admin
  end
end
