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

  # The teacher "Getting Started" page. It shows only teacher content, so students, including a
  # teacher preview student account, can't see it.
  def getting_started?
    !student?
  end

  def authoring?
    teacher? || manager_or_project_admin?
  end

  def authoring_site_redirect?
    teacher? || manager_or_project_admin?
  end

end
