class Admin::SettingsVendorInterface < ActiveRecord::Base
  self.table_name = :admin_settings_vendor_interfaces
  belongs_to :admin_settings, :class_name => "Admin::Settings", :foreign_key => "admin_settings_id"
  belongs_to :probe_vendor_interface, :class_name => "Probe::VendorInterface", :foreign_key => "probe_vendor_interface_id"
end
