class Portal::ClazzPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user && user.has_role?('admin')
        all
      elsif user && (user.is_project_admin? || user.is_project_researcher?)
        # prevents a bunch of unnecessary model loads by not using the user#admin_for_project_teachers and user#researcher_for_project_teachers methods
        teacher_scope = Pundit.policy_scope(user, Portal::Teacher)
        teacher_clazz_ids = teacher_scope
          .joins("INNER JOIN portal_teacher_clazzes __ptc_scope ON __ptc_scope.teacher_id = portal_teachers.id")
          .distinct
          .pluck("__ptc_scope.clazz_id")
        if teacher_clazz_ids.length > 0
          scope.where(id: teacher_clazz_ids)
        else
          none
        end
      elsif user && user.portal_teacher
        clazz_ids = user.portal_teacher.clazz_ids
        scope.where(id: clazz_ids)
      else
        none
      end
    end
  end
end
