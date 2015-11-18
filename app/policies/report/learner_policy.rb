class Report::LearnerPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('manager','admin','researcher')
        all
      elsif user.is_project_admin?
        scope_for_project_ids(user.admin_for_projects.map { |p| p.id  })
      elsif user.is_project_researcher?
        # narrow scope to those students that have signed permission forms associated with the projects
        project_ids = user.researcher_for_projects.map { |p| p.id  }
        scope_for_project_ids(project_ids)
          .joins("left join portal_student_permission_forms on report_learners.student_id = portal_student_permission_forms.portal_student_id")
          .joins("left join portal_permission_forms on portal_student_permission_forms.portal_permission_form_id")
          .where(["portal_permission_forms.project_id in (?)", project_ids])
      else
        none
      end
    end

    private

    def scope_for_project_ids(project_ids)
      # returns learners in classes whose teachers are in a cohorts in the specified project ids
      Report::Learner
        .joins("left join portal_teacher_clazzes on report_learners.class_id = portal_teacher_clazzes.clazz_id")
        .joins("left join admin_cohort_items on portal_teacher_clazzes.teacher_id = admin_cohort_items.item_id and admin_cohort_items.item_type = 'Portal::Teacher'")
        .joins("left join admin_cohorts on admin_cohort_items.admin_cohort_id = admin_cohorts.id")
        .where(["admin_cohorts.project_id in (?)", project_ids])
    end
  end

  def index?
    manager_or_researcher_or_project_researcher?
  end

  def logs_query?
    manager_or_researcher_or_project_researcher?
  end

  def update_learners?
    manager_or_researcher_or_project_researcher?
  end
end
