class Portal::PermissionForm < ActiveRecord::Base
  self.table_name = :portal_permission_forms
  attr_accessible :name, :url

  has_many :portal_student_permission_forms, :dependent => :destroy, :class_name => "Portal::StudentPermissionForm", :foreign_key => "portal_permission_form_id"
  has_many :students, :through => :portal_student_permission_forms, :class_name => "Portal::Student", :source => "portal_student_id"

end
