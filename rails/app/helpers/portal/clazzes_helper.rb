module Portal::ClazzesHelper
  def render_portal_clazz_partial(name, portal_clazz=@portal_clazz)
    render :partial => name, :locals => {:portal_clazz => portal_clazz}
  end

  def student_roster_props(portal_clazz=@portal_clazz)

    can_edit = portal_clazz.changeable?(current_visitor)

    students = []
    roster = StudentRoster.new(portal_clazz)
    roster.each do |roster_row|
      is_oauth_user= roster_row.student.user.is_oauth_user?
      students.push({
        student_id: roster_row.student.id,
        user_id: roster_row.student.user.id,
        student_clazz_id: roster_row.portal_student_clazz.id,
        name: roster_row.name,
        username: is_oauth_user ? "" : roster_row.login, # this was commented out in the original template for oauth users: {roster_row.student.user.authentications[0].provider.titleize} user
        last_login: roster_row.last_login,
        assignments_started: roster_row.assignments_started,
        can_remove: can_edit,
        can_reset_password: policy(roster_row.student.user).reset_password?,
        is_oauth_user: is_oauth_user,
        oauth_provider: is_oauth_user ? roster_row.student.user.authentications[0].provider : "n/a"
      })
    end

    # adapted from old student_add_dropdown helper
    other_students = []
    if can_edit
      other_clazzes = portal_clazz.school ? (portal_clazz.school.clazzes.includes(:students => :user) - [portal_clazz]) : []
      other_students = other_clazzes.map { |c| c.students}.flatten.uniq
      other_students = other_students - portal_clazz.students
      other_students.reject! { |s| s.user.nil?}
      other_students.compact!
      other_students = other_students.sort { |a,b| (a.user.last_name.upcase <=> b.user.last_name.upcase) }
      other_students = other_students.map { |s| {id: s.id, name: "#{s.user.last_name }, #{s.user.first_name}", username: s.user.login } }
    end

    return {
      canEdit: can_edit,
      allowDefaultClass: current_settings.allow_default_class,
      clazz: {
        id: portal_clazz.id,
        name: portal_clazz.name
      },
      students: students
    }
  end

end