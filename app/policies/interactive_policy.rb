class InteractivePolicy < ApplicationPolicy

  def new_or_create?
    admin?
  end

  def update_edit_or_destroy?
    admin?
  end

  def import_model_library?
    admin?
  end

end
