class Portal::StudentPolicy < ApplicationPolicy
  def show?
    owner? || admin?
  end
end
