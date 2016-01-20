class ResourcePagePolicy < ApplicationPolicy
  def edit_grade_levels?
    admin? || owner?
  end

  def edit_subject_areas?
    admin? || owner?
  end

  def edit_cohorts?
    admin?
  end
end
