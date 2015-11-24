class ExternalActivityPolicy < ApplicationPolicy

  def preview_index?
    true
  end

  def publish?
    new_or_create?
  end

  def republish?
    request_is_peer?
  end

  def duplicate?
    new_or_create?
  end

  def matedit?
    true
  end

  def set_private_before_matedit?
    changeable?
  end

  def copy?
    true
  end

end
