class Portal::TeacherPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('manager','admin','researcher')
        all
      elsif user.is_project_admin? || user.is_project_researcher?
        teachers = []
        if user.is_project_admin?
          teachers << user.admin_for_project_teachers
        end
        if user.is_project_researcher?
          teachers << user.researcher_for_project_teachers
        end
        teachers.flatten.uniq
      else
        none
      end
    end
  end

  def show?
    owner? || admin?
  end

end
