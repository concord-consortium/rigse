class Portal::PermissionForm < ApplicationRecord
  self.table_name = :portal_permission_forms

  has_many :portal_student_permission_forms, :dependent => :destroy, :class_name => "Portal::StudentPermissionForm", :foreign_key => "portal_permission_form_id"
  has_many :students, :through => :portal_student_permission_forms, :class_name => "Portal::Student" #, :source => "portal_student_id"  # REMOVED due to `Unknown key: :source` error
  belongs_to :project, :class_name => 'Admin::Project'

  def fullname
    if project
      "#{project.name}: #{name}"
    else
      name
    end
  end

end
