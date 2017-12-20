class HomePolicy < ApplicationPolicy

  def admin?
    manager_or_researcher_or_project_researcher?
  end

  def recent_activity?
    teacher?
  end

  def authoring?
    teacher? || manager_or_project_admin?
  end

end
