class Portal::TeacherPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.is_project_admin?
        user.admin_for_project_teachers
      elsif user.has_role?('manager','admin','researcher')
        all
      else
        none
      end
    end
  end

end
