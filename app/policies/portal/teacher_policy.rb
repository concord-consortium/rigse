class Portal::TeacherPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user && user.has_role?('manager','admin','researcher')
        all
      elsif user && (user.is_project_admin? || user.is_project_researcher?)
        # prevents a bunch of unnecessary model loads by not using the user#admin_for_project_teachers and user#researcher_for_project_teachers methods
        scope
          .joins("INNER JOIN admin_cohort_items __aci_scope ON __aci_scope.item_id = portal_teachers.id")
          .joins("INNER JOIN admin_cohorts __ac_scope ON __ac_scope.id = __aci_scope.admin_cohort_id")
          .joins("INNER JOIN admin_project_users __apu_scope ON __apu_scope.project_id = __ac_scope.project_id")
          .where("__aci_scope.item_type = 'Portal::Teacher'")
          .where("__apu_scope.user_id = ? AND (__apu_scope.is_admin = 1 OR __apu_scope.is_researcher = 1)", user.id)
          .uniq
      else
        none
      end
    end
  end

  def show?
    owner? || admin?
  end

end
