class Probe::ProbeType < ActiveRecord::Base
  self.table_name = "probe_probe_types"

  include Changeable

  acts_as_replicatable
  belongs_to :user

  has_many :calibrations, :class_name => 'Probe::Calibration'

  before_create :generate_uuid


end
