class UserPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin','manager')
        all
      elsif user.is_project_admin?
        # project admins can see teachers or students in their admined cohorts
        # or edit_by_project_admin any portal teacher
        teachers_and_students_ids = (user.admin_for_project_teachers + user.admin_for_project_students).uniq.map {|u| u.user_id}
        scope.where(["(users.id IN (?)) OR (users.id IN (SELECT user_id FROM portal_teachers))", teachers_and_students_ids])
      else
        none
      end
    end
  end

  def index?
    manager_or_project_admin?
  end

  def edit_by_project_admin?
    project_admin? && record.portal_teacher
  end
  def update_by_project_admin?
    project_admin? && record.portal_teacher
  end

  def show?
    changeable?
  end

  def switch?
    changeable?
  end

  def confirm?
    admin_or_manager?
  end

  def reset_password?
    changeable?
  end

  def preferences?
    changeable?
  end
end
