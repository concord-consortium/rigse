class Portal::PermissionFormPolicy < ApplicationPolicy

  def index?
    admin_or_manager_project_admin?
  end

  def update_forms?
    admin_or_manager_project_admin?
  end

  def create?
    admin_or_manager_project_admin?
  end

  def destroy?
    admin_or_manager_project_admin?
  end
end
