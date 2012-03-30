class Ccportal::ClassStudent < Ccportal::Ccportal
  self.table_name = :portal_class_students
  set_primary_key :class_student_id

  belongs_to :student, :foreign_key => :member_id, :class_name => 'Ccportal::Student'
  belongs_to :course, :foreign_key => :class_id, :class_name => 'Ccportal::Course'

  def self.findStudentsByClassId(classId)
    students = []
    css = self.find(:all, :conditions => { :class_id => classId })
    css.each do |cs|
      begin 
        student = Ccportal::Member.find(cs.member_id)
        students << student
      rescue ActiveRecord::RecordNotFound => e
        AltLogger.getLogger.error("Classtudent.findStudentsByClassId: #{e.to_s}: Can't find member [#{cs.member_id}]")
      end
    end
    students
  end

end
