class UserPolicy < ApplicationPolicy

  def index?
    manager_or_researcher?
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
    original_user && original_user.has_role?('admin', 'manager')
  end

  def confirm?
    admin_or_manager?
  end

  def reset_password?
    changeable?
  end

end
