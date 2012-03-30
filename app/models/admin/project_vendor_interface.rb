class Admin::ProjectVendorInterface < ActiveRecord::Base
  self.table_name = :admin_project_vendor_interfaces
  belongs_to :admin_project, :class_name => "Admin::Project", :foreign_key => "admin_project_id"
  belongs_to :probe_vendor_interface, :class_name => "Probe::VendorInterface", :foreign_key => "probe_vendor_interface_id"
end
