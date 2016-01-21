class API::V1::OfferingPolicy < ApplicationPolicy

  def show?
    is_class_teacher_or_admin?
  end

  def collaborators_data?
    request_is_peer?
  end

  private
  def is_admin?
    user && user.has_role?("admin")
  end

  def is_class_teacher?
    return false unless user && user.portal_teacher
    offering = Portal::Offering.find_by_id(params[:id])
    offering && offering.clazz.teachers.include?(user.portal_teacher)
  end

  def is_class_teacher_or_admin?
    return is_class_teacher? || is_admin?
  end

end
