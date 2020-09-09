module Portal::StudentClazzesHelper

  def students_in_class(all_students)
    all_students.compact.uniq.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end

  def make_chosen(id)
    return <<-EOF
      <script type="text/javascript">new Chosen($('#{id}'))</script>
    EOF
  end

end
