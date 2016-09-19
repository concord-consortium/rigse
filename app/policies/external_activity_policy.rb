class ExternalActivityPolicy < ApplicationPolicy
  include MaterialSharedPolicy

  def preview_index?
    true
  end

  def publish?
    new_or_create? || author?
  end

  def republish?
    request_is_peer?
  end

  def duplicate?
    new_or_create?
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
    user.present?
  end

  # the basic edit form lets a user change the publication status, subject areas,
  # and grade levels. So if a user can change any of those things then they should
  # be able to see the basic form
  def edit_basic?
    edit_publication_status? || edit_subject_areas? || edit_grade_levels?
  end

  # we need to let owners update the settings too
  # currently this means the owner could hack things and
  # update some of the non basic settings too
  def update?
    admin? || owner?
  end

  def archive?
    admin_or_material_admin? || owner?
  end

  def unarchive?
    admin_or_material_admin? || owner?
  end

  def material_admin?
    user.present? && record.projects.detect{ |p| user.is_project_admin? p }
  end

  def admin_or_material_admin?
    admin? || material_admin?
  end
end
