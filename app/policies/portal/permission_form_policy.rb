class Portal::PermissionFormPolicy < ApplicationPolicy

  def index?
    manager_or_project_admin?
  end

  def update_forms?
    manager_or_project_admin?
  end

  def create?
    manager_or_project_admin?
  end

  def destroy?
    manager_or_project_admin?
  end
end
