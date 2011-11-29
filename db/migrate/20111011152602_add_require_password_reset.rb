class AddRequirePasswordReset < ActiveRecord::Migration
  def self.up
    add_column :users, :require_password_reset, :boolean, :default => false
  end

  def self.down
    remove_column :users, :require_password_reset
  end
end
