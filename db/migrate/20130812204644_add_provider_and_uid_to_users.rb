class AddProviderAndUidToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    add_index :users, [:provider, :uid]
  end

  def self.down
    remove_column :users, :uid
    remove_column :users, :provider

    remove_index :users, [:provider, :uid]
  end
end
