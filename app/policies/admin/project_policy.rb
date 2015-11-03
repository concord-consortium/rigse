class Admin::ProjectPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        scope.all
      elsif user.is_project_admin?
        user.admin_for_projects
      else
        # hack to return an empty relation pre Rails 4
        scope.where("1 = 0")
      end
    end
  end

  def index?
    admin_or_project_admin?
  end

  def update_edit_or_destroy?
    admin_or_project_admin?
  end

  def not_anonymous?
    admin_or_project_admin?
  end
end
