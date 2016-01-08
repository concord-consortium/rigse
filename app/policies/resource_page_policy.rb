class ResourcePagePolicy < ApplicationPolicy
  def edit_cohorts?
    admin?
  end
end
