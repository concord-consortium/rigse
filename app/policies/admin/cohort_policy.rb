class Admin::CohortPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        all
      elsif user.is_project_admin?
        user.admin_for_project_cohorts
      else
        none
      end
    end
  end

end
