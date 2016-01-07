module MaterialSharedPolicy

  def edit_all?
    admin? || user && (user.admin_for_projects & record.projects).length > 0
  end

  def edit_projects_or_cohorts?
    admin? || project_admin?
  end

  def edit?
    edit_all? || edit_projects_or_cohorts?
  end

  def update?
    # That's simplification. Theoretically we should also divide update process
    # and authorize separately for projects/cohorts update and other options update.
    # However it doesn't really make sense, as a project admin can assign material to
    # his own project and then edit other settings too. It would be pseudo-security.
    edit?
  end
end
