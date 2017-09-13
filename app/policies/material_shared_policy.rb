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
  # Is this material visible to the specified user
  #
  def visible?

    #
    # Admins or material admins can view all.
    #
    if admin_or_material_admin? 
        return true
    end

    #
    # Allow owner to view
    #
    if owner?
        return true
    end

    #
    # If it's not published, do not allow anonymous 
    #
    if record.publication_status != 'published'
        if user.nil?
            return false
        end
    end

    #
    # If material has cohorts, only teachers in those cohorts can view.
    #
    if record.cohorts.length > 0

        if user.nil?
            return false
        end

        if  user.portal_teacher &&
            user.portal_teacher.cohorts

            user_cohort_ids     = user.portal_teacher.cohorts.map {|c| c.id}
            material_cohort_ids = record.cohorts.map { |c| c.id }

            if (user_cohort_ids & material_cohort_ids).empty?
                #
                # No intersection, deny access.
                #
                return false
            end
        end
    end

    #
    # For assessments, deny access to anonymous and student.
    #
    if  record.respond_to?(:is_assessment_item) &&
        record.is_assessment_item

        if user.nil? || user.only_a_student?
            return false
        end

    end

    return true

  end

end
