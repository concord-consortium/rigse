module Portal::StudentClazzesHelper
  
  def students_in_class(all_students)
    all_students.compact.uniq.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end 
  

  def student_add_dropdown(clazz)
    span_id = "student_add_dropdown";
    span_class = "nobreak"
    span_tag = "<span id='#{span_id}' class='#{span_class}'>"

    existing_students = clazz.teacher ? (clazz.teacher.students - clazz.students) : nil
    student_list = (students_in_class(clazz.students)).sort { |a,b| (a.user.last_name <=> b.user.last_name) }
    
    if (existing_students && existing_students.size > 0)
      default_value = "Add a registered #{current_project.name} student"        
      options = [[default_value,default_value]]
      options = options + (existing_students.map { |s| [ truncate("#{s.last_name}, #{s.first_name} (#{s.login})",30), s.id ] })
      select_opts = options_for_select(options, :selected => default_value)
      return <<-EOF
          #{span_tag}
          #{select_tag('student_id',  select_opts ,:id => 'student_id_selector')}
          #{button_to_remote("Add", :url => {:controller => 'portal/clazzes', :action=>'add_student', :id => clazz}, :with => "'student_id='+$('student_id_selector').value")}
        </span>
      EOF
    end
    return "#{span_tag}</span>"
  end


end
