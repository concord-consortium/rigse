module Portal::ClazzesHelper
  def render_portal_clazz_partial(name, portal_clazz=@portal_clazz)
    render :partial => name, :locals => {:portal_clazz => portal_clazz}
  end

  def student_roster_props(portal_clazz=@portal_clazz)

    can_edit = policy(portal_clazz).update_roster?

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
        oauth_provider: is_oauth_user ? roster_row.student.user.authentications[0].provider : "n/a",
        is_teacher_preview_student: roster_row.student.is_teacher_preview_student
      })
    end

    return {
      canEdit: can_edit,
      canManageStudents: policy(portal_clazz).manage_students?,
      allowDefaultClass: current_settings.allow_default_class,
      clazz: {
        id: portal_clazz.id,
        name: portal_clazz.name,
        teacherIds: portal_clazz.teachers.pluck(:id)
      },
      students: students
    }
  end

end
