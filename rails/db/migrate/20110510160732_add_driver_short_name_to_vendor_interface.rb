class AddDriverShortNameToVendorInterface < ActiveRecord::Migration[5.1]
  def self.up
    add_column :probe_vendor_interfaces, :driver_short_name, :string
  end

  def self.down
    remove_column :probe_vendor_interfaces, :driver_short_name
  end
end
