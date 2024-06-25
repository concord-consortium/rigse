class Portal::PermissionFormPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        all
      elsif user.is_project_admin? || user.is_project_researcher?
        where = []
        params = {}
        if user.is_project_admin?
          where << "(project_id in (:admin_project_ids))"
          params[:admin_project_ids] = user.admin_for_projects.map { |p| p.id }
        end
        if user.is_project_researcher?
          where << "(project_id in (:researcher_project_ids))"
          params[:researcher_project_ids] = user.researcher_for_projects.map { |p| p.id }
        end
        scope.where([where.join(" OR "), params])
      else
        none
      end
    end
  end

  def index?
    manager_or_researcher_or_project_researcher?
  end

  def external_report_query?
    manager_or_researcher_or_project_researcher?
  end

  def external_report_query_jwt?
    manager_or_researcher_or_project_researcher?
  end

  def external_report_learners_from_jwt?
    manager_or_researcher_or_project_researcher?
  end

  def update_forms?
    manager_or_researcher_or_project_researcher?
  end

  # API::V1::PermissionFormsController:

  def create?
    # In fact this method should be named: admin_or_project_admin_or_project_researcher
    manager_or_researcher_or_project_researcher?
  end

  def update?
    admin? || record && (project_admin?(record.project) || project_researcher?(record.project))
  end

  def destroy?
    admin? || record && (project_admin?(record.project))
  end

  def search_teachers?
    # In fact this method should be named: admin_or_project_admin_or_project_researcher
    manager_or_researcher_or_project_researcher?
  end
end
