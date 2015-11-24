class Report::LearnerPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('manager','admin','researcher')
        all
      elsif user.is_project_admin? || user.is_project_researcher?
        where = []
        params = {}

        if user.is_project_admin?
          where << "(report_learners.class_id IN (
            SELECT DISTINCT portal_teacher_clazzes.clazz_id
            FROM portal_teacher_clazzes, admin_cohort_items, admin_cohorts
            WHERE portal_teacher_clazzes.teacher_id = admin_cohort_items.item_id
              AND admin_cohort_items.item_type = 'Portal::Teacher'
              AND admin_cohort_items.admin_cohort_id = admin_cohorts.id
              AND admin_cohorts.project_id IN (:admin_project_ids)))"
          params[:admin_project_ids] = user.admin_for_projects.map { |p| p.id }
        end

        if user.is_project_researcher?
          where << "(report_learners.learner_id IN (
            SELECT DISTINCT report_learners.learner_id
            FROM report_learners, portal_teacher_clazzes, admin_cohort_items, admin_cohorts, portal_permission_forms, portal_student_permission_forms
            WHERE report_learners.class_id = portal_teacher_clazzes.clazz_id
              AND portal_teacher_clazzes.teacher_id = admin_cohort_items.item_id
              AND admin_cohort_items.item_type = 'Portal::Teacher'
              AND admin_cohort_items.admin_cohort_id = admin_cohorts.id
              AND admin_cohorts.project_id IN (:researcher_project_ids)
              AND report_learners.student_id = portal_student_permission_forms.portal_student_id
              AND portal_student_permission_forms.portal_permission_form_id = portal_permission_forms.id
              AND portal_permission_forms.project_id IN (:researcher_project_ids)))"
          params[:researcher_project_ids] = user.researcher_for_projects.map { |p| p.id }
        end

        scope.where([where.join(" OR "), params])
      else
        none
      end
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
