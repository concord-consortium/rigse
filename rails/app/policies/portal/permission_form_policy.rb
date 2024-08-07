class Portal::PermissionFormPolicy < ApplicationPolicy

  # User by API::V1::ReportLearnersEsController:

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        scope.all
      elsif user.is_project_admin? || user.is_project_researcher?
        admin_project_ids = user.admin_for_projects.select(:id)
        researcher_project_ids = user.researcher_for_projects.select(:id)
        scope.where("project_id IN (?) OR project_id IN (?)", admin_project_ids, researcher_project_ids)
      else
        scope.none
      end
    end
  end

  def report_learners_es_index?
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

  # API::V1::PermissionFormsController:

  def index?
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
