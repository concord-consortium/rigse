class Portal::StudentPolicy < ApplicationPolicy
  def show?
    owner? || admin? || 
    (user.portal_teacher && record.teachers.include?(user.portal_teacher)) ||
    # this isn't the most efficient way to do this, but it's not too bad and this is not a high-traffic path
    (record.projects.any? { |p| user.is_project_admin?(p) })
  end
end
