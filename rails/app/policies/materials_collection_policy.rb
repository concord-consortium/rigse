class MaterialsCollectionPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user && user.has_role?('admin')
        all
      elsif user
        # prevents a bunch of unnecessary model loads by not using the user#admin_for_project_cohorts method
        scope
          .joins("INNER JOIN admin_project_users __apu_scope ON __apu_scope.project_id = materials_collections.project_id")
          .where("__apu_scope.user_id = ? AND __apu_scope.is_admin = 1", user.id)
      else
        none
      end
    end
  end

  def new?
    admin_or_project_admin?
  end

  def create?
    check_project
  end

  def edit?
    check_project
  end

  def update?
    check_project
  end

  def show?
    check_project
  end

  def destroy?
    check_project
  end

  def sort_materials?
    check_project
  end

  def remove_material?
    check_project
  end

  private

  def check_project
    if(record.project)
      admin? || user.is_project_admin?(record.project)
    else
      admin_or_project_admin?
    end
  end

end
