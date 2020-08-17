module Portal::TeachersHelper

  def teachers_in_class(all_teachers)
    all_teachers.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end

  def make_chosen(id)
    return <<-EOF
      <script type="text/javascript">new Chosen($('#{id}'))</script>
    EOF
  end

end
