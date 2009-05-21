class DeviceConfig < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor_interface

  acts_as_replicatable
  include Changeable
end
