module MaterialSharedPolicy

  def new_or_create?
    admin? || project_admin?
  end

  def edit_settings?
    admin_or_material_admin?
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

  #
  # Is this material visible to the current_user
  #
  def visible?

    #
    # Admins or material admins can view all.
    #
    if admin_or_material_admin? 
        return true
    end

    #
    # If it has cohorts, only teachers in those cohorts can view.
    #
    if material.cohorts.length > 0
        if current_user.nil?
            return false
        end
        if  current_user.portal_teacher &&
            current_user.portal_teacher.cohorts

            cohort_ids = current_user.portal_teacher.cohorts.map {|c| c.id}
        end
    end

    #
    # For assessment, deny access to anonymous 
    #
    if material.is_assessment_item
        if current_user.nil? || current_user.only_a_student?
            return false
        end
    end

    if current_user.portal_teacher?
       
    end

    return false

  end

end
