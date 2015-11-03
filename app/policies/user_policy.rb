class UserPolicy < ApplicationPolicy

  def index?
    manager_or_researcher?
  end

  def edit_by_project_admin?
    changeable? || project_admin?
  end
  def update_by_project_admin?
    changeable? || project_admin?
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

end
