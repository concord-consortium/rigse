class ExternalActivityPolicy < ApplicationPolicy
  include MaterialSharedPolicy

  def permitted_attributes
    if user.has_role?('admin')
      ExternalActivity.attribute_names.map(&:to_sym)
    else
      ExternalActivity.attribute_names.map(&:to_sym) - %i(id is_official)
    end
  end

  def publish?
    new_or_create? || author?
  end

  def republish?
    request_is_peer?
  end

  def duplicate?
    new_or_create? || (teacher? && record.teacher_copyable)
  end

  def matedit?
    # FIXME: this was done because the external_activity#user might not be
    # the same as the actual author in LARA. That could happen if an admin published
    # a material for the actual author. However this is problematic because sometimes
    # the email of users changes
    edit? || (user && (record.author_email == user.email))
  end

  def set_private_before_matedit?
    changeable?
  end

  def copy?
    not_anonymous?
  end

  # the basic edit form lets a user change the publication status, subject areas,
  # and grade levels. So if a user can change any of those things then they should
  # be able to update the basic form
  def update_basic?
    edit_publication_status? || edit_grade_levels? || edit_subject_areas? || edit_sensors?
  end

  # FIMXE: This single update permission is used by all users when they are changing the
  # settings. The fine grained permissions in MaterialSharedPolicy
  # only control which fields are visible. So for example it would be possible for an
  # owner who is not an admin to change some advanced settings.
  def update?
    # the edit here refers to the edit in material_shared_policy
    # that edit lets any admin, project_admin, or material_admin to edit the material
    # admins and material_admins makes sense in this case. project_admins require access
    # so they can update project and project cohorts of materials they aren't the owner of
    # and are not part of their project yet
    # This is needed when there are multiple authors on a project. An non project admin
    # author creates the material.  Then the project admins needs to find it and mark
    # configure the advanced configuration options. Otherwise a portal admin needs to
    # get involved.
    edit? || owner?
  end

  def update_by_url?
    edit? || owner?
  end

  def archive?
    admin_or_material_admin? || owner?
  end

  def unarchive?
    admin_or_material_admin? || owner?
  end

  def edit_collections?
    admin?
  end

  def update_collections?
    admin?
  end

end
