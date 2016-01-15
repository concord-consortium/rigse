class Dataservice::ExternalActivityDataController < ApplicationController

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  private

  def pundit_user_not_authorized(exception)
    learner = Portal::Learner.find_by_id_or_key(params[:id] || params[:key])
    learner_deets = LearnerDetail.new(learner)
    visitor = current_visitor ? current_visitor.name : 'anonymous'
    error_string = "Auth error for #{visitor} - #{learner_deets}"
    raise ActionController::RoutingError.new(error_string)
  end

  public

  def create
    authorize Dataservice::ProcessExternalActivityDataJob
    learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
    # TODO: wrap this in a begin/rescue/end and return a real-ish error
    Delayed::Job.enqueue Dataservice::ProcessExternalActivityDataJob.new(learner.id, request.body.read)
    render :status => 201, :nothing => true
  end

end
