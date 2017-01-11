class Admin::TagPolicy < ApplicationPolicy

  def index?
    admin?
  end

  def update_edit_or_destroy?
    admin?
  end

  def not_anonymous?
    admin?
  end

end
