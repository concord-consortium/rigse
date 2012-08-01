module Portal::StudentClazzesHelper
  
  def students_in_class(all_students)
    all_students.compact.uniq.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end 
  
  def make_chosen(id)
    return <<-EOF
      <script type="text/javascript">new Chosen($('#{id}'))</script>
    EOF
  end

  def student_add_dropdown(clazz)
    span_id = "student_add_dropdown";
    span_class = "nobreak"
    span_tag = "<span id='#{span_id}' class='#{span_class}'>"

    other_clazzes = []
    default_value =  "Search for registered student."
    if clazz.school 
      other_clazzes = (clazz.school.clazzes.includes(:students => :user) - [clazz])
      if clazz.school.name && clazz.school.name.length > 1
        default_value = "Search for registered student."
      end
    end
    other_students  = other_clazzes.map { |c| c.students}.flatten.uniq
    other_students  = other_students - clazz.students
    other_students.reject! { |s| s.user.nil?}
    other_students.compact!
    student_list = other_students.sort { |a,b| (a.user.last_name.upcase <=> b.user.last_name.upcase) }
    
    if (student_list && student_list.size > 0)
      # default_value = "Add a registered #{APP_CONFIG[:site_name]} student"
      # default_value = "Add another student from this school."
      options = [[default_value,default_value]]
      options = options + (student_list.map { |s| [ truncate(s.user.name_and_login,:length => 50), s.id ] })
      select_opts = options_for_select(options, :selected => default_value)
      span_tag = <<-EOF
          #{span_tag}
          <table width='100%'><tr>
          <td>#{select_tag('student_id',  select_opts ,:id => 'student_id_selector')}</td>
          <td>#{button_to_remote("Add", :url => {:controller => 'portal/clazzes', :action=>'add_student', :id => clazz}, :with => "'student_id='+$('student_id_selector').value")}</td>
          <td>&nbsp;&nbsp;or&nbsp;&nbsp;</td>
          </tr></table>
        </span>
        #{make_chosen('student_id_selector')}
      EOF
    end
    return "#{span_tag}</span>".html_safe
  end


end
