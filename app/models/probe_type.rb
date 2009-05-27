class ProbeType < ActiveRecord::Base
  include Changeable
  
  acts_as_replicatable

  has_many :activities, :class_name => "Itsi::Activity"

  belongs_to :user
  
  has_many :data_collectors
  # has_many :probes
  # has_many :vendor_interfaces, :through => :probes
  
  has_many :calibrations

  before_create :generate_uuid


end
