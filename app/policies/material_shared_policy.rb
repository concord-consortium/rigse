module MaterialSharedPolicy

  def new_or_create?
    admin? || project_admin?
  end

  def edit_settings?
    project_admin_of_material?
  end

  def edit_credits?
    project_admin_of_material?
  end

  def edit_projects?
    # Admin or admin of any project.
    admin? || project_admin?
  end

  def edit_cohorts?
    # Admin or admin of any project.
    admin? || project_admin?
  end

  # owners are allowed to edit the publication status of their materials
  def edit_publication_status?
    project_admin_of_material? || owner?
  end

  # owners are allowed to edit the grade levels of their materials
  def edit_grade_levels?
    project_admin_of_material? || owner?
  end

  # owners are allowed to edit the subject areas of their materials
  def edit_subject_areas?
    project_admin_of_material? || owner?
  end

  def edit?
    project_admin_of_material? || edit_projects? || edit_cohorts?
  end

  def update?
    # That's simplification. Theoretically we should also divide update process
    # and authorize separately for projects/cohorts update and other options update.
    # However it doesn't really make sense, as a project admin can assign material to
    # his own project and then edit other settings too.
    edit?
  end

  def destroy?
    admin?
  end

  def project_admin_of_material?
    # Admin or admin of a project assigned to this material.
    admin? || user && (user.admin_for_projects & record.projects).length > 0
  end


end
