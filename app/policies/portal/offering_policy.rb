class Portal::OfferingPolicy < ApplicationPolicy
  # Used by API::V1::OfferingsController:
  def api_show?
    class_teacher_or_admin?
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

  def get_recent_student_report?
    class_teacher_or_admin? || class_student?
  end

  def report?
    class_teacher_or_admin?
  end

  def external_report?
    class_teacher_or_admin?
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
