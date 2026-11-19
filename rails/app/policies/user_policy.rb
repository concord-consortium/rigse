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

  # Nobody can edit a teacher learner account, not even admins. Its name comes from its teacher,
  # and nobody signs in to it with a login and password. This includes its project roles.
  def limited_edit?
    return false if record_teacher_learner?
    admin_or_manager? || (project_admin? && record.portal_teacher)
  end

  def limited_update?
    return false if record_teacher_learner?
    admin_or_manager? || (project_admin? && record.portal_teacher)
  end

  def edit?
    return false if record_teacher_learner?
    admin_or_project_admin_for_user?
  end

  def update?
    return false if record_teacher_learner?
    # the preferences page uses the update action so the user needs to be able to update themselves.
    its_me? || admin_or_project_admin_for_user?
  end

  def make_admin?
    admin_or_manager?
  end

  def show?
    admin_or_project_admin_for_user? || limited_edit?
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
    # A project admin must not reach a teacher they can't switch to, for example a teacher outside
    # their cohorts or a teacher who is an admin, through "Switch back to teacher". So only a user
    # who can switch to the teacher can switch to the teacher's learner account.
    return switch_to_linked_teacher? if record_teacher_learner?

    (project_admin_for_user? && record_not_admin?) ||  admin_or_manager? || switching_back?
  end

  def confirm?
    project_admin_for_user? || admin_or_manager?
  end

  def reset_password?
    # Nobody can reset a teacher learner account's password. Nobody signs in to it with one, and
    # the roles that could reset it can switch to it instead.
    return false if record_teacher_learner?
    (project_admin_for_user? && record_not_admin?) || admin_or_manager? || am_teacher? || its_me?
  end

  # Setting your own password at /change_password/0 (PasswordsController). Users are sent there
  # when they must set a new password, and any signed-in user can open it. A teacher learner
  # account cannot use it.
  def change_own_password?
    its_me? && !record_teacher_learner?
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

  def admin_or_project_admin_for_user?
    admin_or_manager? || (project_admin_for_user? && record_not_admin?)
  end

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

  def record_teacher_learner?
    !!record&.teacher_learner?
  end

  def switching_back?
    record == original_user
  end

  def switch_to_linked_teacher?
    teacher_user = record.linked_teacher_user
    return false unless teacher_user

    # This policy has the same user, original_user, request, and params readers as the context
    # that Pundit gives, so it can be the context of the teacher's policy.
    UserPolicy.new(self, teacher_user).switch?
  end

  def am_teacher?
    if record.portal_student && user.portal_teacher
      return user.portal_teacher.students.include? record.portal_student
    end
    return false
  end
end
