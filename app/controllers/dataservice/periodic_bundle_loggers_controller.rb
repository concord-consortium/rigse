class Dataservice::PeriodicBundleLoggersController < ApplicationController
  # restrict access to admins or bundle formatted requests 
  include RestrictedBundleController

  # GET /dataservice/periodic_bundle_loggers/1
  # GET /dataservice/periodic_bundle_loggers/1.xml
  def show
    @dataservice_bundle_logger = Dataservice::PeriodicBundleLogger.find(params[:id])
    eportfolio_bundle = @dataservice_bundle_logger.sail_bundle
    # FIXME How do we now associate launch process events since bundle_content != session?
    # For now, the in_progress_bundle is still being created, so just use that.
    if ipb = @dataservice_bundle_logger.learner.bundle_logger.in_progress_bundle
      launch_event = Dataservice::LaunchProcessEvent.create(
        :event_type => Dataservice::LaunchProcessEvent::TYPES[:bundle_requested],
        :event_details => "Learner session data loaded. Loading activity content...",
        :bundle_content => ipb
      )
    end
    respond_to do |format|
      # format.html # show.html.erb
      format.xml  { render :xml => eportfolio_bundle }
      format.bundle {render :xml => eportfolio_bundle }
    end
  end
end
