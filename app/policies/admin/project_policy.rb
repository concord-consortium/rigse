class Admin::ProjectPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        all
      elsif user.is_project_admin?
        user.admin_for_projects
      elsif user.is_project_researcher?
        user.researcher_for_projects
      else
        none
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

  # Visible on the search page, home page, navigation bar, etc.
  def visible?
    record.public || admin? || user && user.is_project_member?(record)
  end

  def assign_to_material?
    admin? || user && user.is_project_admin?(record)
  end
end
