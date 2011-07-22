class Probe::DataFilter < ActiveRecord::Base
  set_table_name "probe_data_filters"

  include Changeable
  acts_as_replicatable

  belongs_to :user
  has_many :calibrations, :class_name => 'Probe::Calibration'

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
end
