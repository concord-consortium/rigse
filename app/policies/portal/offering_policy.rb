class Portal::OfferingPolicy < ApplicationPolicy

  def show?
    class_teacher_or_admin?
  end

  private
  def class_teacher?
    return false unless user && user.portal_teacher
    record && record.clazz.teachers.include?(user.portal_teacher)
  end

  def class_teacher_or_admin?
    return class_teacher? || admin?
  end

end
