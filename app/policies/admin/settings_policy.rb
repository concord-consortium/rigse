class Admin::SettingsPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        all
      else
        none
      end
    end
  end

  def index?
    admin?
  end
  def new_or_create?
    admin?
  end
  def update_edit_or_destroy?
    admin?
  end
end
