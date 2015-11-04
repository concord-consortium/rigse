class Dataservice::BlobPolicy < ApplicationPolicy

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
