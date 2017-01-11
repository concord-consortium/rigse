class MaterialsCollectionPolicy < ApplicationPolicy

  def index?
    admin?
  end

  def update_edit_or_destroy?
    admin?
  end

  def not_anonymous?
    admin?
  end

  def sort_materials?
    admin?
  end

end
