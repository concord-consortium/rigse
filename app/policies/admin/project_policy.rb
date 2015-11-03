class Admin::ProjectPolicy < ApplicationPolicy

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
