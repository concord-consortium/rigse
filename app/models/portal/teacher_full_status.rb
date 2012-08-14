class Portal::TeacherFullStatus < ActiveRecord::Base
  self.table_name = :portal_teacher_full_status
  
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id"
  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"

end