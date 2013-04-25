class Dataservice::ExternalActivityDataController < ApplicationController

  def create
    learner_id = params[:id]
    if learner = Portal::Learner.find(learner_id)
      if learner.user == current_visitor
        Delayed::Job.enqueue Dataservice::ProcessExternalActivityDataJob.new(learner_id, params[:content])
        render :status => 201, :nothing => true
        return
      end
    end
    raise ActionController::RoutingError.new('Not Found')
  end

end
