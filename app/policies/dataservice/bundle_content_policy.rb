class Dataservice::BundleContentPolicy < ApplicationPolicy

  def index?
    admin?
  end

  def show?
    admin?
  end

  def new?
    true
  end

  def edit?
    admin?
  end

  def create?
    true
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

end
