class Portal::OfferingPolicy < ApplicationPolicy
  # Used by API::V1::OfferingsController:
  def api_show?
    class_teacher_or_admin? || class_student? || class_researcher?
  end

  def api_index?
    teacher? || admin? || student?
  end

  def api_create_for_external_activity?
    teacher? || admin?
  end

  class Scope < Scope
    def resolve
      return none unless user

      if user.has_role?('admin')
        all
      elsif user.is_project_admin? || user.is_project_researcher?
        # prevents a bunch of unnecessary model loads by not using the user#admin_for_project_teachers and user#researcher_for_project_teachers methods
        teacher_ids_subquery = Pundit.policy_scope(user, Portal::Teacher).select(:id)
        scope
          .joins("INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.clazz_id = portal_offerings.clazz_id")
          .where(portal_teacher_clazzes: { teacher_id: teacher_ids_subquery })
          .distinct

      elsif user.portal_teacher
        scope.where(clazz_id: user.portal_teacher.clazz_ids)
      elsif user.portal_student
        # students can only see their own offerings
        # in the controller the list of students in the offering is filtered
        # to only include the student requesting the offering
        scope.where(clazz_id: user.portal_student.clazz_ids)
      else
        none
      end
    end
  end

  # Used by API::V1::ReportsController:
  def api_report?
    class_teacher_or_admin?
  end

  # Used by Portal::OfferingsController:
  def show?
    # all teachers of the class and admins can see the offering
    return true if class_teacher_or_admin?

    # only students of the class can see the offering
    return false if !class_student?

    # always allow access if the show_feedback param is present so the student can see feedback
    # NOTE: @params is set in ApplicationPolicy#initialize at runtime but not in the test suite
    # except for the test for the show_feedback parameter which is why the present? check is needed
    return true if @params.present? && @params[:show_feedback].present?

    # check if the offering is locked for the student
    locked = record.locked
    metadata = UserOfferingMetadata.find_by(user_id: user.id, offering_id: record.id)
    if metadata.present?
      locked = metadata.locked
    end

    # if the offering is locked, the student cannot see it
    return !locked
  end

  def destroy?
    class_teacher_or_admin?
  end

  def activate?
    class_teacher_or_admin?
  end

  def deactivate?
    class_teacher_or_admin?
  end

  def update?
    class_teacher_or_admin?
  end

  # A forwarded-student request is bound to student scope exclusively: when
  # acting as the forwarded student we must not fall through to the
  # teacher/admin branch, since current_user's portal roles are independent of
  # the forwarded identity.
  def update_student_metadata?
    return forwarded_update_offering_state? if oidc_context.acting_as_forwarded_user?
    class_teacher_or_admin?
  end

  def answers?
    class_teacher_or_admin? || class_student?
  end

  def report?
    class_teacher_or_admin? || class_researcher?
  end

  def external_report?
    researcher_view = params[:researcher].present? && params[:researcher] != 'false'

    if class_teacher_or_admin?
      true
    elsif researcher_view && class_researcher?
      true
    else
      class_student? &&
      record &&
      record.runnable &&
      record.runnable.respond_to?(:external_reports) &&
      params[:report_id] &&
      (report = record.runnable.external_reports.find(params[:report_id])) &&
      report.allowed_for_students
    end
  end


  def offering_collapsed_status?
    teacher?
  end

  private

  def forwarded_update_offering_state?
    ctx = oidc_context
    return false unless ctx.capability?('update_offering_state')
    return false unless student? && class_student?
    return false unless target_user_is_acting_student?

    if record.id == ctx.origin_offering_id
      true
    else
      open_only_write?
    end
  end

  def target_user_is_acting_student?
    @params.present? && @params[:user_id].to_s == user.id.to_s
  end

  # Non-origin offerings may only be opened (unlocked / made visible). Require at
  # least one permitted state key and deny any write that locks or hides.
  def open_only_write?
    return false unless @params.present?
    return false unless @params.key?(:locked) || @params.key?(:active)
    cast = ActiveModel::Type::Boolean.new
    locked = cast.cast(@params[:locked])
    active = cast.cast(@params[:active])
    !(locked == true || active == false)
  end

  def class_teacher?
    user && record && record.clazz.is_teacher?(user)
  end

  def class_student?
    user && record && record.clazz.is_student?(user)
  end

  def class_teacher_or_admin?
    class_teacher? || admin?
  end

  def class_researcher?
    user && record && user.is_researcher_for_clazz?(record.clazz)
  end
end
