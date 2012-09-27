class Dataservice::BucketLoggersController < ApplicationController
  # restrict access to admins or bundle formatted requests 
  include RestrictedBundleController

  # GET /dataservice/bucket_loggers/1
  # GET /dataservice/bucket_loggers/1.xml
  def show
    @dataservice_bucket_logger = Dataservice::BucketLogger.find(params[:id])
    bundle = @dataservice_bucket_logger.most_recent_content
    # FIXME How do we now associate launch process events since bucket_content != session?
    # For now, the in_progress_bundle is still being created, so just use that.
    if ipb = @dataservice_bucket_logger.learner.bundle_logger.in_progress_bundle
      launch_event = Dataservice::LaunchProcessEvent.create(
        :event_type => Dataservice::LaunchProcessEvent::TYPES[:bundle_requested],
        :event_details => "Learner session data loaded. Loading activity content...",
        :bundle_content => ipb
      )
    end
    respond_to do |format|
      # format.html # show.html.erb
      format.bundle {
        send_data(
          bundle,
          :type => 'application/octet-stream',
          :filename => "data-#{@dataservice_bucket_logger.id}.dat",
          :disposition => 'inline'
        )
      }
    end
  end

  def show_by_learner
    @dataservice_bucket_logger = Dataservice::BucketLogger.find_or_create_by_learner_id(params[:id])
    bundle = @dataservice_bucket_logger.most_recent_content
    # FIXME How do we now associate launch process events since bucket_content != session?
    # For now, the in_progress_bundle is still being created, so just use that.
    if ipb = @dataservice_bucket_logger.learner.bundle_logger.in_progress_bundle
      launch_event = Dataservice::LaunchProcessEvent.create(
        :event_type => Dataservice::LaunchProcessEvent::TYPES[:bundle_requested],
        :event_details => "Learner session data loaded. Loading activity content...",
        :bundle_content => ipb
      )
    end
    respond_to do |format|
      # format.html # show.html.erb
      format.bundle {
        send_data(
          bundle,
          :type => 'application/octet-stream',
          :filename => "data-#{@dataservice_bucket_logger.id}.dat",
          :disposition => 'inline'
        )
      }
    end
  end
end
