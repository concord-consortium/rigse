class Fixups

  def self.destroy_teacher(teacher)
    teacher.clazzes.each(&:destroy)
    teacher.clazzes=[]
    # destroy could damage learner data.
    teacher.delete
    teacher = nil
  end

  def self.destroy_student(student)
    student.user.security_questions.each(&:destroy)
    student.destroy
    student = nil
  end

  def self.remove_teachers_test_students
    teachers = Portal::Teacher.all
    teachers.each do |teacher|
      user = teacher.user
      if user
        if user.portal_student
          puts "removing one student (#{user.portal_student.id}) (#{user.name} | #{user.id}) (#{user.portal_student.created_at})"
          self.destroy_student(user.portal_student)
          user.portal_student = nil
        end
      else
        puts "removing one bad teacher (#{teacher.id}) (null user) (#{teacher.created_at})"
        self.destroy_teacher(teacher)
      end
    end
  end

end
