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
  attr_accessible :signed, :portal_student_id, :portal_student,
    :portal_permission_form_id, :portal_permission_form
end
