require 'large_class'
require 'mixed_runnable_type_class'

module MockData
  def self.default_teacher
    return @default_teacher if @default_teacher
    teacher_user = User.find_by_login 'teacher'
    @default_teacher = teacher_user.portal_teacher
  end

  def self.default_student
    return @default_student if @default_student
    student_user = User.find_by_login 'student'
    @default_student = student_user.portal_student
  end
end
