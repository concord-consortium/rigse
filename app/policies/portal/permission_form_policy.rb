class Portal::PermissionFormPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('manager','admin','researcher')
        all
      elsif user.is_project_admin?
        Portal::PermissionForm.where(["project_id in (?)", user.admin_for_projects.map { |p| p.id  }])
      else
        none
      end
    end
  end

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
