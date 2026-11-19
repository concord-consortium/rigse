class HomePolicy < ApplicationPolicy

  def admin?
    manager_or_researcher_or_project_researcher?
  end

  def recent_activity?
    teacher?
  end

  # The student home page. It needs a student record.
  def my_classes?
    student?
  end

  # The teacher "Getting Started" page. Anyone can see it except a teacher learner account,
  # which would otherwise see teacher instructions after a switch in another tab.
  def getting_started?
    !user&.teacher_learner?
  end

  def authoring?
    teacher? || manager_or_project_admin?
  end

  def authoring_site_redirect?
    teacher? || manager_or_project_admin?
  end

end
