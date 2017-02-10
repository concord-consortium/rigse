class Dataservice::ExternalActivityDataController < ApplicationController

  # Disable CSRF token verification, as this API is meant to be used by external sites (e.g. LARA).
  skip_before_filter :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  private

  def pundit_user_not_authorized(exception)
    learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
    learner_deets = LearnerDetail.new(learner)
    visitor = current_visitor ? current_visitor.name : 'anonymous'
    error_string = "Auth error for #{visitor} - #{learner_deets}"
    raise ActionController::RoutingError.new(error_string)
  end

  def handle_versioned_protocol(version)
    learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
    case version
      when "1"
        Delayed::Job.enqueue Dataservice::V1::ProcessExternalActivityDataJob.new(learner.id, request.body.read, Time.now)
        render :status => 201, :nothing => true
      else
        render :status => 501, :text  => "Can't find protocol for version: #{version}"
    end
  end

  public

  def create
    authorize Dataservice::ProcessExternalActivityDataJob
    if params[:version].present?
      handle_versioned_protocol(params[:version])
    else
      learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
      Delayed::Job.enqueue Dataservice::ProcessExternalActivityDataJob.new(learner.id, request.body.read)
      render :status => 201, :nothing => true
    end
  end

  def create_by_protocol_version
    authorize Dataservice::ProcessExternalActivityDataJob
    handle_versioned_protocol(params[:version])
  end

end
