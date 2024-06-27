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
          researcher_project_ids = user.researcher_for_projects.select do |project|
            user.is_project_researcher?(project, check_can_manage_permission_forms: true)
          end.map(&:id)
          where << "(project_id in (:researcher_project_ids))"
          params[:researcher_project_ids] = researcher_project_ids
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

  def permission_forms_v2_index?
    user && user.can_manage_permission_forms?
  end

  def projects?
    user && user.can_manage_permission_forms?
  end

  def create?
    user && user.can_manage_permission_forms?
  end

  def update?
    record && user && user.can_manage_permission_forms?(record.project)
  end

  def destroy?
    admin? || record && (project_admin?(record.project))
  end

  def search_teachers?
    user && user.can_manage_permission_forms?
  end
end
