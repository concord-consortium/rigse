# Headless policy for LearnerModeController: `authorize :learner_mode, :enter_learner_mode?`.
# The switch target never comes from the request. It comes from the teacher-to-learner link,
# so these rules only check who the current user is.
class LearnerModePolicy < ApplicationPolicy

  # Only a teacher can enter learner mode.
  def enter_learner_mode?
    teacher?
  end

  # Only a teacher's learner account can exit learner mode, and only if its teacher still exists.
  def exit_learner_mode?
    user.present? && user.teacher_learner? && user.linked_teacher_user.present?
  end

end
