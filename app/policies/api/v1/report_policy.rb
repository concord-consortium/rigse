class API::V1::ReportPolicy < ApplicationPolicy


  def show?
    class_teacher_or_admin? || is_the_student?
  end

  private

  def is_admin?
    user && user.has_role?("admin")
  end

  def clazz
    record.offering.clazz
  end

  def class_teacher?
    record.is_teacher? user
  end

  def is_the_student?
    record.is_report_for_student? user
  end

  def class_teacher_or_admin?
    class_teacher? || admin?
  end

end
