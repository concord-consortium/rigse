Factory.define :device_config do |f|
  f.user              { |d| Factory.next :admin_user }
  f.vendor_interface  { |d| VendorInterface.find(:first) || Factory(:vendor_interface) }
  f.config_string     'none'
end
