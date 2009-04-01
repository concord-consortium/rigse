class DeviceConfig < ActiveRecord::Base
  include Changeable
  acts_as_replicatable
  
  belongs_to :user
  belongs_to :vendor_interface
  has_many :calibrations
end
