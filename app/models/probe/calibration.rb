class Probe::Calibration < ActiveRecord::Base
  set_table_name "probe_calibrations"

  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  belongs_to :user
  belongs_to :physical_unit, :class_name => 'Probe::PhysicalUnit'
  belongs_to :probe_type, :class_name => 'Probe::ProbeType'
  belongs_to :data_filter, :class_name => 'Probe::DataFilter'
  
  delegate :unit_symbol_text, :unit_symbol, :quantity, :to=>:physical_unit
  
  def self.new (options=nil)
    c = super(options)
    c.probe_type = ProbeType.find_by_name("Raw Voltage") unless c.probe_type
    c.data_filter = DataFilter.find(:first) unless c.data_filter
    c
  end
  
end
