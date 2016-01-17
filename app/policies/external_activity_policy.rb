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
    true
  end

  # owners can edit some basic settings of external activities
  def edit_basic?
    edit? || owner?
  end

  # we need to let owners update the settings too
  # currently this means the owner could hack things and
  # update some of the non basic settings too
  def update?
    edit? || owner?
  end

end
