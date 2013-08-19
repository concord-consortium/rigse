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
    NoCache.add_headers(response.headers)
    respond_to do |format|
      # format.html # show.html.erb
      format.xml  { render :xml => eportfolio_bundle }
      format.bundle {render :xml => eportfolio_bundle }
    end
  end

  def session_end_notification
    if pbl = Dataservice::PeriodicBundleLogger.find(params[:id])
      if ipb = pbl.learner.bundle_logger.in_progress_bundle
        launch_event = ::Dataservice::LaunchProcessEvent.create(
          :event_type => ::Dataservice::LaunchProcessEvent::TYPES[:bundle_saved],
          :event_details => "Learner session data saved. Activity should now be closed.",
          :bundle_content => ipb
        )
        pbl.learner.bundle_logger.end_bundle( { :body => "" } )
      end
      render :xml => '<ok/>', :status => :created
    else
      render :xml => '<notFound/>', :status => 404
    end
  end
end
