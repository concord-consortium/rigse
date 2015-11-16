class Portal::PermissionFormPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('manager','admin','researcher')
        all
      elsif user.is_project_admin?
        scope_for_projects(user.admin_for_projects)
      elsif user.is_project_researcher?
        scope_for_projects(user.researcher_for_projects)
      else
        none
      end
    end

    private

    def scope_for_projects(projects)
      Portal::PermissionForm.where(["project_id in (?)", projects.map { |p| p.id  }])
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
