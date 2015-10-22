class ActivityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    !user.anonymous?
  end

  def edit?
    record.changeable?(user)
  end
end
