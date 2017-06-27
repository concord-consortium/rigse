module MaterialSharedPolicy

  def new_or_create?
    admin? || project_admin?
  end

  def edit_settings?
    admin_or_material_admin?
  end

  def edit_standards_settings?
    author? || admin_or_material_admin?
  end

  def edit_credits?
    admin_or_material_admin?
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
    admin_or_material_admin? || owner?
  end

  # owners are allowed to edit the grade levels of their materials
  def edit_grade_levels?
    admin_or_material_admin? || owner?
  end

  # owners are allowed to edit the subject areas of their materials
  def edit_subject_areas?
    admin_or_material_admin? || owner?
  end

  def edit?
    admin_or_material_admin? || edit_projects? || edit_cohorts?
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

  def material_admin?
    user.present? && record.projects.detect{ |p| user.is_project_admin? p }
  end

  def admin_or_material_admin?
    admin? || material_admin?
  end

end
