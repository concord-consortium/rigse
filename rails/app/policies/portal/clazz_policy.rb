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
    class_teacher_or_admin? || class_student? || class_project_admin? ||class_researcher?
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
    class_teacher_or_admin? || 
    (params[:researcher] && 
      (class_project_admin? || class_researcher?)
    )
  end

  def roster?
    class_teacher_or_admin? || class_project_admin?
  end

  def update_roster?
    class_teacher_or_admin? || class_project_admin?
  end

  # A forwarded-student request is bound to student scope exclusively and never
  # also gets the teacher/admin update_roster? branch.
  def add_to_class?
    return forwarded_enroll_student? if oidc_context.acting_as_forwarded_user?
    update_roster?
  end

  def external_report?
    class_teacher_or_admin? || class_researcher? || class_student?
  end

  # Used by Portal::API::V1::PermissionFormsController:

  def class_permission_forms?
    admin? || class_teacher? || class_project_admin? || (user && record && user.is_researcher_for_clazz?(record, check_can_manage_permission_forms: true))
  end

  # This is a special page that admins can use to add students to other classes
  # Regular teachers are not allowed to do this. That is because when the student
  # runs assignments in the second class they won't see their work from the first
  # class.
  def manage_students?
    admin? || class_project_admin?
  end

  private

  def forwarded_enroll_student?
    ctx = oidc_context
    return false unless ctx.capability?('enroll_student')
    return false unless student?
    return false unless target_is_acting_student?
    origin_clazz = ctx.origin_clazz
    return false unless origin_clazz
    return false if record.is_archived?
    (origin_clazz.teachers.to_a & record.teachers.to_a).any?
  end

  # Require every provided identifier (user_id and/or student_id) to resolve to
  # the acting student, and at least one to be present. find_student_from_params
  # prioritizes student_id over user_id, so an any-match check would be
  # exploitable (user_id=self + student_id=other would enroll other).
  def target_is_acting_student?
    return false unless @params.present?
    checked = false
    if @params[:student_id].present?
      checked = true
      return false unless user.portal_student && @params[:student_id].to_s == user.portal_student.id.to_s
    end
    if @params[:user_id].present?
      checked = true
      return false unless @params[:user_id].to_s == user.id.to_s
    end
    checked
  end

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
