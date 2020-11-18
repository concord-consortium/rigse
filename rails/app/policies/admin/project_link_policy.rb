class Admin::ProjectLinkPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user && user.has_role?('admin')
        all
      elsif user
        scope
          .joins("INNER JOIN admin_project_users __apu_scope ON __apu_scope.project_id = admin_project_links.project_id")
          .where("__apu_scope.user_id = ? AND __apu_scope.is_admin = 1", user.id)
      else
        none
      end
    end
  end

  def new?
    admin_or_project_admin?
  end

  def create?
    # if the project_link has a project already, require membership
    if(record.project)
      (admin? || user.is_project_admin?(record.project))
    else
      # don't allow creation of project links without projects
      false
    end
  end

  def update?
    # if the project_link has a project already, require membership
    if(record.project)
      admin? || user.is_project_admin?(record.project)
    else
      # only admins can fix project_links that don't have a project
      admin?
    end
  end

  def show?
    if(record.project)
      admin? || user.is_project_member?(record.project)
    else
      # only admins can view project_links that don't have a project
      admin?
    end
  end

  def destroy?
    update?
  end
end
