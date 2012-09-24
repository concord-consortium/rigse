class AddAdminAccountsToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :admin_accounts, :string
  end

  def self.down
    remove_column :admin_projects, :admin_accounts
  end
end
