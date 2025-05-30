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

  # Used by API::V1::ClassesController:
  def api_show?
    class_teacher_or_admin? || class_student? || class_researcher?
  end

  def api_create?
    teacher? || admin?
  end

  def mine?
    teacher? || student?
  end

  def log_links?
    admin?
  end

  def set_is_archived?
    class_teacher_or_admin?
  end

  # Used by Portal::ClazzesController:
  def materials?
    if params[:researcher]
      class_teacher_or_admin? || class_researcher?
    else
      class_teacher_or_admin?
    end
  end

  def external_report?
    class_teacher_or_admin? || class_researcher? || class_student?
  end

  # Used by Portal::API::V1::PermissionFormsController:

  def class_permission_forms?
    admin? || class_teacher? || class_project_admin? || (user && record && user.is_researcher_for_clazz?(record, check_can_manage_permission_forms: true))
  end

  private

  def class_student?
    user && record && record.is_student?(user)
  end

  def class_teacher?
    user && record && record.is_teacher?(user)
  end

  def class_teacher_or_admin?
    class_teacher? || admin?
  end

  def class_researcher?
    user && record && user.is_researcher_for_clazz?(record)
  end

  def class_project_admin?
    user && record && user.is_project_admin_for_clazz?(record)
  end
end
