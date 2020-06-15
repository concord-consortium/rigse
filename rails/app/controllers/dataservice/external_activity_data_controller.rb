class Dataservice::ExternalActivityDataController < ApplicationController

  private

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
