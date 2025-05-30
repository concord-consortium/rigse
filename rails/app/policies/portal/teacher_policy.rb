class Portal::TeacherPolicy < ApplicationPolicy

  def self.teacher_query(user)
    return "
      SELECT portal_teachers.id FROM portal_teachers
      INNER JOIN
        admin_cohort_items __aci_scope ON (__aci_scope.item_id = portal_teachers.id)
      INNER JOIN
          admin_cohorts __ac_scope ON (__ac_scope.id = __aci_scope.admin_cohort_id)
      INNER JOIN
          admin_project_users __apu_scope ON (__apu_scope.project_id = __ac_scope.project_id)
      WHERE
          __aci_scope.item_type = 'Portal::Teacher'
      AND
          __apu_scope.user_id = #{user.id}
      AND
          (__apu_scope.is_admin = 1 OR (__apu_scope.is_researcher = 1 AND (__apu_scope.expiration_date IS NULL OR expiration_date > '#{Date.today.to_fs(:db)}')))
      UNION
        SELECT id
        FROM portal_teachers
        WHERE user_id = #{user.id}
    "
  end

  class Scope < Scope
    def resolve
      if user && user.has_role?('admin')
        all
      elsif user && (user.is_project_admin? || user.is_project_researcher?)
        # prevents a bunch of unnecessary model loads by not using the model scopes
        # Also covers some tricky edge cases.
        # See this bug: https://www.pivotaltracker.com/story/show/169465198
        sql = Portal::TeacherPolicy::teacher_query(user)
        ids = Portal::Teacher.connection.select_values(sql)
        # Return a new scope selecting those records:
        scope
          .where('portal_teachers.id IN (?)', ids)
          .distinct

      elsif (user.portal_teacher)
        scope.where('user_id = (?)', user.id)
      end
    end
  end

  def can_view_teacher?
    return false if user.nil?
    return true if owner? || admin?

    if user.is_project_admin? || user.is_project_researcher?
      sql = Portal::TeacherPolicy.teacher_query(user)
      teacher_ids = Portal::Teacher.connection.select_values(sql)
      return teacher_ids.include?(record.id)
    end

    false
  end

  def show?
    can_view_teacher?
  end

  def get_teacher_project_views?
    can_view_teacher?
  end

end
