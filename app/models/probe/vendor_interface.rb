class Probe::VendorInterface < ActiveRecord::Base
  set_table_name "probe_vendor_interfaces"

  include Changeable
  
  acts_as_replicatable

  has_many :users
  has_many :device_configs, :class_name => 'Probe::DeviceConfig'
  # belongs_to :author, :class_name => 'User'
  # has_many :probes
  # has_many :probe_types, :class_name => 'Probe::ProbeType', :through => :probes
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    def deviceid(shortname)
      self.find_by_short_name(shortname).device_id
    end
  end

 
end

# For more info see:
# https://confluence.concord.org/display/TMS/OT+Schema
# http://source.concord.org/sensor/apidocs/index-all.html
# http://source.concord.org/sensor/apidocs/constant-values.html#org.concord.sensor.device.impl.DeviceID.PSEUDO_DEVICE
#
# currently defined list of: vendor_interface.short_name
# "vernier_goio"
# "dataharvest_easysense_q"
# "fourier_ecolog"
# "pasco_airlink"
# "pasco_sw500"
# "ti_cbl2"
# "pseudo_interface"
#
# org.concord.sensor.device.impl.DeviceID
# CCPROBE_VERSION_0	70
# CCPROBE_VERSION_1	71
# CCPROBE_VERSION_2	72
# COACH	80
# DATA_HARVEST_ADVANCED	41
# DATA_HARVEST_CF	45
# DATA_HARVEST_QADVANCED	42
# DATA_HARVEST_USB	40
# FOURIER	30
# IMAGIWORKS_SD	55
# IMAGIWORKS_SERIAL	50
# PASCO_AIRLINK	61
# PASCO_SERIAL	60
# PSEUDO_DEVICE	0
# TI_CONNECT	20
# VERNIER_GO_LINK	10
