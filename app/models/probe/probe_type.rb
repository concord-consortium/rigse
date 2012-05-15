class Probe::ProbeType < ActiveRecord::Base
  self.table_name = "probe_probe_types"

  include Changeable
  
  acts_as_replicatable

  has_many :activities, :class_name => "Itsi::Activity"

  belongs_to :user
  
  has_many :data_collectors, :class_name => 'Embeddable::DataCollector'
  # has_many :probes
  # has_many :vendor_interfaces, :class_name => 'Probe::VendorInterface', :through => :probes
  
  has_many :calibrations, :class_name => 'Probe::Calibration'

  before_create :generate_uuid


end
