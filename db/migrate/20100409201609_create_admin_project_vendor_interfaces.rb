class CreateAdminProjectVendorInterfaces < ActiveRecord::Migration
  def self.up
    create_table :admin_project_vendor_interfaces do |t|
      t.integer     :admin_project_id
      t.integer     :probe_vendor_interface_id
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_project_vendor_interfaces
  end
end
