class Portal::OfferingPolicy < ApplicationPolicy
  # Used by API::V1::OfferingsController:
  def api_show?
    class_teacher_or_admin? || class_student? || class_researcher?
  end

  def api_index?
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
    # if locked, only show if the show_feedback param is present so the student can see feedback
    class_teacher_or_admin? || (class_student? && (!record.locked || params[:show_feedback].present?))
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
