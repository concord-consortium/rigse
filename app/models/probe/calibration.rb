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
  
  def otml_filter_tag_symbol
    self.data_filter.otrunk_object_class.split(".")[-1].to_sym
  end

  def otml_filter_tag_attributes
    attrib = {}
    attrib[:k0] = self.k0 if self.k0
    attrib[:k1] = self.k1 if self.k1
    attrib[:k2] = self.k2 if self.k2
    attrib[:k3] = self.k3 if self.k3
    attrib
  end
end
