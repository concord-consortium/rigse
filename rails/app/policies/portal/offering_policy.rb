class Portal::OfferingPolicy < ApplicationPolicy
  # Used by API::V1::OfferingsController:
  def api_show?
    class_teacher_or_admin? || class_student?
  end

  def api_index?
    teacher? || admin?
  end

  class Scope < Scope
    def resolve
      if user && user.has_role?('admin')
        all
      elsif user && (user.is_project_admin? || user.is_project_researcher?)
        # prevents a bunch of unnecessary model loads by not using the user#admin_for_project_teachers and user#researcher_for_project_teachers methods
        teacher_scope = Pundit.policy_scope(user, Portal::Teacher)
        teacher_clazz_ids = teacher_scope
          .joins("INNER JOIN portal_teacher_clazzes __ptc_scope ON __ptc_scope.teacher_id = portal_teachers.id")
          .uniq
          .pluck("__ptc_scope.clazz_id")
        if teacher_clazz_ids.length > 0
          scope.where(clazz_id: teacher_clazz_ids)
        else
          none
        end
      elsif user && user.portal_teacher
        clazz_ids = user.portal_teacher.clazz_ids
        scope.where(clazz_id: clazz_ids)
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
    class_teacher_or_admin? || (class_student? && !record.locked)
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

  def student_report?
    class_student?
  end

  def report?
    class_teacher_or_admin?
  end

  def external_report?
    if class_teacher_or_admin?
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
end
