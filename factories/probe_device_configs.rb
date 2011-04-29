Factory.define :probe_device_config, :class => Probe::DeviceConfig do |f|
  f.user              { |d| Factory.next :admin_user }
  f.vendor_interface  { |d| Probe::VendorInterface.find(:first) || Factory(:probe_vendor_interface) }
  f.config_string     'none'
end
