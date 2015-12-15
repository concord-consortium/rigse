class Dataservice::ExternalActivityDataController < ApplicationController

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  private

  def pundit_user_not_authorized(exception)
    learner_id = params[:id]
    learner_deets = LearnerDetail.new(learner)
    visitor = current_visitor ? current_visitor.name : 'anonymous'
    error_string = "Auth error for #{visitor} - #{learner_deets}"
    raise ActionController::RoutingError.new(error_string)
  end

  public

  def create
    learner_id = params[:id]
    if learner = Portal::Learner.find(learner_id)
      authorize Dataservice::ProcessExternalActivityDataJob
      # TODO: wrap this in a begin/rescue/end and return a real-ish error
      Delayed::Job.enqueue Dataservice::ProcessExternalActivityDataJob.new(learner_id, request.body.read)
      render :status => 201, :nothing => true and return
    end
    raise ActionController::RoutingError.new('Not Found')
  end

end
