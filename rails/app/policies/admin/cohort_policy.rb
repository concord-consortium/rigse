class Admin::CohortPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user && user.has_role?('admin')
        all
      elsif user
        # prevents a bunch of unnecessary model loads by not using the user#admin_for_project_cohorts method
        scope
          .joins("INNER JOIN admin_project_users __apu_scope ON __apu_scope.project_id = admin_cohorts.project_id")
          .where("__apu_scope.user_id = ? AND __apu_scope.is_admin = 1", user.id)
      else
        none
      end
    end
  end

end
