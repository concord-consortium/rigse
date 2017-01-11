class SearchPolicy < ApplicationPolicy

  def index?
    teacher?
  end

  def unauthorized_user?
    true
  end

  def setup_material_type?
    true
  end

  def get_search_suggestions?
    true
  end

  def get_current_material_unassigned_clazzes?
    teacher?
  end

  def add_material_to_clazzes?
    teacher?
  end

  def get_current_material_unassigned_collections?
    admin?
  end

  def add_material_to_collections?
    admin?
  end

end
