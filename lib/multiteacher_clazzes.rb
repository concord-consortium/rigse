class MultiteacherClazzes

  def self.make_all_multi_teacher
    clazzes = Portal::Clazz.find(:all)  
    clazzes.each do |clazz|
      make_multi_teacher(clazz)
    end
    true
  end
  
  def self.make_multi_teacher(clazz)
    if clazz.teacher_id
      teacher = Portal::Teacher.find(clazz.teacher_id)
      if (teacher)
        teacher.add_clazz(clazz)
      end
    end
  end

end
