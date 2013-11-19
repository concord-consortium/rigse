class Portal::StudentPermissionForm < ActiveRecord::Base
  # Todo someday in app/models/portal.rb?
  # module Portal
  #   def self.table_name_prefix
  #     'portal_'
  #   end
  # end
  self.table_name = :portal_student_permission_forms
  belongs_to :portal_student, :class_name => "Portal::Student"
  belongs_to :portal_permission_form, :class_name => "Portal::PermissionForm"
  attr_accessible :signed
end
