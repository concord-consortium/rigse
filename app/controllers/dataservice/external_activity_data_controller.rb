class Dataservice::ExternalActivityDataController < ApplicationController
  include PeerAccess
  
  private
  def can_create(learner)
    # allow admins and managers to re-post learner data
    # from LARA
    return true if (current_visitor.has_role? "admin")
    return true if (current_visitor.has_role? "manager")
    return true if (current_visitor == learner.user )
    return true if verify_request_is_peer
    raise_auth_error(learner)
  end

  def raise_auth_error(learner)
    learner_deets = LearnerDetail.new(learner)
    visitor = current_visitor ? current_visitor.name : 'anonymous'
    error_string = "Auth error for #{visitor} - #{learner_deets}"
    raise ActionController::RoutingError.new(error_string)
  end

  public
  def create
    learner_id = params[:id]
    if learner = Portal::Learner.find(learner_id)
      if can_create(learner) # If this fails we raise RoutingError('Not Allowed') (see above)
        # TODO: wrap this in a begin/rescue/end and return a real-ish error
        Delayed::Job.enqueue Dataservice::ProcessExternalActivityDataJob.new(learner_id, request.body.read)
        render :status => 201, :nothing => true and return
      end
    end
    raise ActionController::RoutingError.new('Not Found')
  end

end
