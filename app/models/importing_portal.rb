class ImportingPortal < ActiveRecord::Base

  has_many :imported_users, :class_name => "ImportedUser"

end