class Sorting
  class << self
    def sort_students(students)
      students.sort do |a,b|
        group_result = (b.user.group_account_class_id || 0) <=> (a.user.group_account_class_id || 0)
        group_result == 0 ? (a.user.full_name.downcase <=> b.user.full_name.downcase) : group_result
      end
    end

    def sort_by_student(objs)
      objs.sort do |a,b|
        group_result = (b.student.user.group_account_class_id || 0) <=> (a.student.user.group_account_class_id || 0)
        group_result == 0 ? (a.student.user.full_name.downcase <=> b.student.user.full_name.downcase) : group_result
      end
    end
  end
end