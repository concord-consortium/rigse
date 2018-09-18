class API::V1::ReportPolicy < ApplicationPolicy
  include API::V1::PunditSupport

  def show?
    class_teacher_or_admin? || is_the_student?
  end

  private

  def clazz
    record.offering.clazz
  end

  def class_teacher?
    user && (record.is_teacher? user)
  end

  def is_the_student?
    user && (record.is_report_for_student? user)
  end

  def class_teacher_or_admin?
    class_teacher? || admin?
  end

end
