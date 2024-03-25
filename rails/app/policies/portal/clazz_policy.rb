class Portal::ClazzPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return none unless user

      if user.has_role?('admin')
        all
      elsif user.is_project_admin? || user.is_project_researcher?
        # prevents a bunch of unnecessary model loads by not using the user#admin_for_project_teachers and user#researcher_for_project_teachers methods
        teacher_ids_subquery = Pundit.policy_scope(user, Portal::Teacher).select(:id)
        scope
          .joins("INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.clazz_id = portal_clazzes.id")
          .where(portal_teacher_clazzes: { teacher_id: teacher_ids_subquery })
          .distinct
      elsif user.portal_teacher
        scope.where(id: user.portal_teacher.clazz_ids)
      else
        none
      end
    end
  end

  def materials?
    class_teacher? || class_researcher? || admin?
  end

  private

  def class_teacher?
    user && record && record.is_teacher?(user)
  end

  def class_researcher?
    user && record && user.is_researcher_for_clazz?(record)
  end
end
