module Portal::TeachersHelper

  def teachers_in_class(all_teachers)
    all_teachers.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end

  def make_chosen(id)
    return <<-EOF
      <script type="text/javascript">new Chosen($('#{id}'))</script>
    EOF
  end

  def teacher_add_dropdown(clazz)
    span_id = "teacher_add_dropdown";
    span_class = "nobreak"
    span_tag = "<span id='#{span_id}' class='#{span_class}'>"

    other_clazzes = []
    default_value =  "Click and type name to search for registered teacher"
    teacher_list = (!clazz.school.nil?) ? clazz.school.portal_teachers - clazz.teachers : []

    teacher_list = teacher_list.sort { |a,b| (a.list_name <=> b.list_name) }.map { |t| [t.list_name,t.id] }

    if (teacher_list && teacher_list.size > 0)
      options = [[default_value,default_value]]
      options = options + teacher_list
      select_opts = options_for_select(options, :selected => default_value)
      span_tag = <<-EOF
          #{span_tag}
          #{select_tag('teacher_id',  select_opts ,:id => 'teacher_id_selector')}
          #{button_to_remote("Add", :url => {:controller => 'portal/clazzes', :action=>'add_teacher', :id => clazz}, :with => "'teacher_id='+$('teacher_id_selector').value")}
          <div class="note">(Note: Make sure new teacher is registered before trying to add them.)</div>

        #{make_chosen('teacher_id_selector')}
      EOF
    else
      span_tag = <<-EOF
          #{span_tag}
          <div class="note">To share this class with other teachers in your school, first have them create an account. You will then be able to add them here as additional teachers of your class.</div>
      EOF
    end
    return "#{span_tag}</span>".html_safe
  end


end
