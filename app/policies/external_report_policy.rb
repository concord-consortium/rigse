class ExternalReportPolicy < ApplicationPolicy

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
    is_admin
  end

  def show?
    is_admin
  end

  def create?
    is_admin
  end

  def edit?
    is_admin
  end

  def update?
    is_admin
  end

  def changeable?
    is_admin
  end

  private
  def is_admin
    has_roles?('admin')
  end

end
