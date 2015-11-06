class ImagePolicy < ApplicationPolicy

  def index?
    author?
  end

  def new_or_create?
    author?
  end

  def update_edit_or_destroy?
    author? && changeable?
  end

end
