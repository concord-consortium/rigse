class AddRpcAdminToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :rpc_admin_login, :text
    add_column :admin_projects, :rpc_admin_email, :text
    add_column :admin_projects, :rpc_admin_password, :text
    add_column :admin_projects, :word_press_url, :text
  end

  def self.down
    remove_column :admin_projects, :rpc_admin_login
    remove_column :admin_projects, :rpc_admin_email
    remove_column :admin_projects, :rpc_admin_password
    remove_column :admin_projects, :word_press_url
  end
end
