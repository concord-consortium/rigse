class CommonsLicensePolicy < ApplicationPolicy
  def index?
    admin_or_manager?
  end

  def show?
    admin_or_manager?
  end

  def new_or_create?
    admin_or_manager?
  end

  def update_edit_or_destroy?
    admin_or_manager?
  end
end
