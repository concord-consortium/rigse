class UserPolicy < ApplicationPolicy

  def index?
    manager_or_researcher?
  end

  def edit?
    changeable? || project_admin?
  end

  def show?
    changeable?
  end

  def switch?
    manager_or_admin?
  end

  def confirm?
    manager_or_admin?
  end

end
