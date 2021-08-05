class AddRequirePasswordReset < ActiveRecord::Migration[5.1]
  def self.up
    add_column :users, :require_password_reset, :boolean, :default => false
  end

  def self.down
    remove_column :users, :require_password_reset
  end
end
