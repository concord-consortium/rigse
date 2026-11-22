# Switches between a teacher and the teacher's own learner account (a separate student account).
# Neither switch action reads a user ID from the request: the target always comes from the
# teacher-to-learner link. Neither action sets session[:original_user_id], so the admin
# "Switch back" link keeps working as it does today.
#
# The switches use POST, so the form security token protects them. With GET, another website
# could switch a signed-in teacher, or create a learner account, with no click.
class LearnerModeController < ApplicationController

  # GET /learner_mode
  # The explanation page that a teacher sees before the first switch. Its "Continue" button
  # posts to enter_learner_mode.
  def explain_learner_mode
    # Already in learner mode, for example after a click in a stale tab. Go home with no error.
    return redirect_to(view_context.current_user_home_path) if in_learner_mode?

    authorize :learner_mode, :enter_learner_mode?
  end

  # POST /learner_mode/enter
  def enter_learner_mode
    # Already in learner mode, for example after a click in a stale tab. Go home with no error.
    return redirect_to(view_context.current_user_home_path) if in_learner_mode?

    authorize :learner_mode, :enter_learner_mode?

    teacher = current_user.portal_teacher
    learner_user = teacher.teacher_preview_student&.user

    if learner_user.nil?
      begin
        learner_user = teacher.find_or_create_teacher_preview_student!
      rescue ActiveRecord::ActiveRecordError => e
        Rails.logger.error("Could not create learner account for teacher #{teacher.id}: #{e.class}: #{e.message}")
        flash['alert'] = "We couldn't start learner mode. Please try again."
        return redirect_to view_context.current_user_home_path
      end
    end

    switch_to(learner_user)
  end

  # POST /learner_mode/exit
  def exit_learner_mode
    # Already switched back, for example after a click in a stale tab. Go home with no error.
    return redirect_to(view_context.current_user_home_path) if current_user&.has_teacher_preview_student?

    authorize :learner_mode, :exit_learner_mode?
    switch_to(current_user.previewing_teacher_user)
  end

  private

  def in_learner_mode?
    current_user.present? && current_user.teacher_preview_student? && current_user.previewing_teacher_user.present?
  end

  # Like UsersController#switch, but it only keeps the admin switch values that are already
  # in the session. It never sets them.
  def switch_to(target_user)
    original_user_id = session[:original_user_id]
    recently_switched_from_users = session[:recently_switched_from_users]

    sign_out current_user
    sign_in target_user

    session[:original_user_id] = original_user_id if original_user_id
    session[:recently_switched_from_users] = recently_switched_from_users if recently_switched_from_users

    redirect_to view_context.current_user_home_path
  end

end
