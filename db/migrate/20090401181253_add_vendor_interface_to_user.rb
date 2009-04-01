class AddVendorInterfaceToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :vendor_interface_id, :integer
  end

  def self.down
    remove_column :users, :vendor_interface_id
  end
end
