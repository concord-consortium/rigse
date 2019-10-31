class Portal::TeacherPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user && user.has_role?('manager','admin','researcher')
        all
      elsif user && (user.is_project_admin? || user.is_project_researcher?)
        # prevents a bunch of unnecessary model loads by not using the
        # user#admin_for_project_teachers and user#researcher_for_project_teachers methods.
        # We have to look through project cohort items, and also check if the
        # user is a teacher (edge case) in a cohort they are not admin for ...
        # See this bug: https://www.pivotaltracker.com/story/show/169465198
        sql = "
          SELECT DISTINCT `portal_teachers`.* FROM
          (
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
                      (__apu_scope.is_admin = 1 OR __apu_scope.is_researcher = 1)
              UNION
                  SELECT id
                  FROM portal_teachers
                  WHERE user_id = #{user.id}
          ) as all_teachers
          JOIN portal_teachers ON portal_teachers.id = all_teachers.id
        "

        ids = Portal::Teacher.connection.select_all(sql).map { |i| i['id'] }
        # Return a new scope selecting those records:
        scope
          .where('portal_teachers.id IN (?)', ids)
          .uniq

      elsif (user.portal_teacher)
        scope.where('user_id = (?)', user.id)
      end
    end
  end

  def show?
    owner? || admin?
  end

end
