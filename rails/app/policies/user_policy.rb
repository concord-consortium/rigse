class UserPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.has_role?('admin','manager')
        all
      elsif user.is_project_admin?
        # project admins can see teachers, students, researchers, and other
        # project admins in their admined cohorts or limited_edit any
        # portal teacher
        admin_and_researcher_ids = (user.admin_for_project_admins + user.admin_for_project_researchers).uniq.map {|u| u.id}
        teachers_and_students_ids = (user.admin_for_project_teachers + user.admin_for_project_students).uniq.map {|u| u.user_id}
        user_ids = (admin_and_researcher_ids + teachers_and_students_ids).uniq
        scope.where(["(users.id IN (?)) OR (users.id IN (SELECT user_id FROM portal_teachers))", user_ids])
      else
        none
      end
    end
  end

  def index?
    manager_or_project_admin?
  end

  def limited_edit?
    admin_or_manager? || (project_admin? && record.portal_teacher)
  end

  def limited_update?
    admin_or_manager? || (project_admin? && record.portal_teacher)
  end

  def edit?
    admin_or_manager? || (project_admin_for_user? && record_not_admin?)
  end

  def update?
    # the preferences page uses the update action so the user needs to be able to update themselves
    its_me? || admin_or_manager? || (project_admin_for_user? && record_not_admin?)
  end

  def make_admin?
    admin_or_manager?
  end

  def show?
    edit? || limited_edit?
  end

  def destroy?
    admin_or_manager?
  end

  def teacher_page?
    # TODO: Fix teacher_controller.rb to use policy using project_admin_for_user?
    admin_or_manager?
  end

  def student_page?
    # TODO: Fix student_controller.rb to use policy using project_admin_for_user?
    admin_or_manager?
  end

  def switch?
    (project_admin_for_user? && record_not_admin?) ||  admin_or_manager? || switching_back?
  end

  def confirm?
    project_admin_for_user? || admin_or_manager?
  end

  def reset_password?
    (project_admin_for_user? && record_not_admin?) || admin_or_manager? || am_teacher? || its_me?
  end

  def add_teachers_to_cohorts?
    user.can_add_teachers_to_cohorts? || admin_or_manager?
  end

  def preferences?
    admin_or_manager? || its_me?
  end

  def favorites?
    its_me?
  end

  private
  def project_admin_for_user?
    return false unless record.respond_to? :cohorts
    return false unless user
    (user.admin_for_project_cohorts & record.cohorts).length > 0
  end

  def record_not_admin?
    !record.has_role?("admin")
  end

  def its_me?
    record == user
  end

  def switching_back?
    record == original_user
  end

  def am_teacher?
    if record.portal_student && user.portal_teacher
      return user.portal_teacher.students.include? record.portal_student
    end
    return false
  end
end
