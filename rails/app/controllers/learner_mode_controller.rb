# Switches between a teacher and the teacher's own learner account (a separate student account).
# Neither action reads a user ID from the request: the target always comes from the
# teacher-to-learner link. Neither action sets session[:original_user_id], so the admin
# "Switch back" link keeps working as it does today.
class LearnerModeController < ApplicationController

  # GET /learner_mode/enter
  # GET /learner_mode/enter?create=true
  def enter_learner_mode
    authorize :learner_mode, :enter_learner_mode?

    teacher = current_user.portal_teacher
    learner_user = teacher.teacher_learner&.user

    if learner_user.nil?
      # First use: explain learner mode. The page's "Continue" button comes back with create=true.
      return render(:enter_learner_mode) unless params[:create] == "true"

      begin
        learner_user = teacher.find_or_create_teacher_learner!
      rescue ActiveRecord::ActiveRecordError => e
        Rails.logger.error("Could not create learner account for teacher #{teacher.id}: #{e.class}: #{e.message}")
        flash['alert'] = "We couldn't start learner mode. Please try again."
        return redirect_to view_context.current_user_home_path
      end
    end

    switch_to(learner_user)
  end

  # GET /learner_mode/exit
  def exit_learner_mode
    authorize :learner_mode, :exit_learner_mode?
    switch_to(current_user.linked_teacher_user)
  end

  private

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
