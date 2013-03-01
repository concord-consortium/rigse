class AddGroupAccountsEnabledToAdminProject < ActiveRecord::Migration
  def change
    add_column :admin_projects, :group_accounts_enabled, :boolean, :default => false
  end
end
