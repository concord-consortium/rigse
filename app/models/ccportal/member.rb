class Ccportal::Member < Ccportal::Ccportal
  self.table_name = :portal_members
  self.primary_key = :member_id

  #############
  ## Teachers #
  #############

  # @@teachers = nil #cache
  # 
  # def courses
  #   Ccportal::Course.findAllForTeacher(self.member_id)
  # end
  # 
  # def school
  #   school = Ccportal::School.find(self.member_school)
  # end
  # 
  # def self.findAllTeachers
  #   @@teachers = @@teachers.nil? ? self.find(:all, :conditions => { :member_type => 'teacher' }) : @@teachers
  # end
  # 
  # def self.clearCache
  #   @@teachers = nil
  # end
  # 
  # #############
  # ## Students #
  # #############
  # 
  # @@students = nil #cache
  # def self.findAllStudents
  #   @@students = @@students.nil? ? self.find(:all, :conditions => { :member_type => 'student' }) : @@students
  # end

end
