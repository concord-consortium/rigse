class Probe::DeviceConfig < ActiveRecord::Base
  set_table_name "probe_device_configs"

  belongs_to :user
  belongs_to :vendor_interface, :class_name => 'Probe::VendorInterface'

  acts_as_replicatable
  include Changeable
end
