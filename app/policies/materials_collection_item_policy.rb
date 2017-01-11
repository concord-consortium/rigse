class MaterialsCollectionItemPolicy < ApplicationPolicy

  def remove_material?
    admin?
  end

end
