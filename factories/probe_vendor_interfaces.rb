Factory.define :probe_vendor_interface, :class => Probe::VendorInterface do |f|
  # f.association :user, :factory=>admin_user
  f.user_id 2 # uh sort of hackish
  f.name  'Vernier Go! Link' 
  f.short_name  'vernier_goio' 
  f.communication_protocol  'usb' 
  f.image  'SensorImages/VernierGoLink_sm.png' 
  f.device_id  10 
  f.description  'The Vernier Go!Link is a USB interface with one sensor port. It works with Vernier analog sensors. The Go!Temp and Go!Motion sensors have Go!Link interfaces integrated into the sensor.'
end

