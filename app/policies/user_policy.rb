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
    manager_or_admin?
  end

  def confirm?
    manager_or_admin?
  end

end
