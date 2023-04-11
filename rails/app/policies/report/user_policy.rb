class Report::UserPolicy < ApplicationPolicy

  def index?
    manager_or_researcher_or_project_researcher?
  end
end
