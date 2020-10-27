class Dataservice::BucketLoggersController < ApplicationController
  # restrict access to admins or bundle formatted requests
  include RestrictedBundleController

  # GET /dataservice/bucket_loggers/1
  # GET /dataservice/bucket_loggers/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @bucket_logger
    @dataservice_bucket_logger = Dataservice::BucketLogger.find(params[:id])
    bundle = @dataservice_bucket_logger.most_recent_content
    if @dataservice_bucket_logger.learner
      # FIXME How do we now associate launch process events since bucket_content != session?
      # For now, the in_progress_bundle is still being created, so just use that.
      if ipb = @dataservice_bucket_logger.learner.bundle_logger.in_progress_bundle
        launch_event = Dataservice::LaunchProcessEvent.create(
          :event_type => Dataservice::LaunchProcessEvent::TYPES[:bundle_requested],
          :event_details => "Learner session data loaded. Loading activity content...",
          :bundle_content => ipb
        )
      end
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Dataservice::BucketLogger
    # authorize @bucket_logger
    # authorize Dataservice::BucketLogger, :new_or_create?
    # authorize @bucket_logger, :update_edit_or_destroy?
    learner = Portal::Learner.find(params[:id]) rescue nil
    raise ActionController::RoutingError.new('Not Found') unless learner

    @dataservice_bucket_logger = Dataservice::BucketLogger.where(learner_id: learner.id).first_or_create
    bundle = @dataservice_bucket_logger.most_recent_content
    # FIXME How do we now associate launch process events since bucket_content != session?
    # For now, the in_progress_bundle is still being created, so just use that.
    if ipb = @dataservice_bucket_logger.learner.bundle_logger.in_progress_bundle
      Dataservice::LaunchProcessEvent.create(
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

  def show_by_name
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Dataservice::BucketLogger
    # authorize @bucket_logger
    # authorize Dataservice::BucketLogger, :new_or_create?
    # authorize @bucket_logger, :update_edit_or_destroy?
    @dataservice_bucket_logger = Dataservice::BucketLogger.find_by_name(params[:name])
    raise ActionController::RoutingError.new('Not Found') unless @dataservice_bucket_logger

    bundle = @dataservice_bucket_logger.most_recent_content

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

  def show_log_items_by_learner
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Dataservice::BucketLogger
    # authorize @bucket_logger
    # authorize Dataservice::BucketLogger, :new_or_create?
    # authorize @bucket_logger, :update_edit_or_destroy?
    learner = Portal::Learner.find(params[:id]) rescue nil
    raise ActionController::RoutingError.new('Not Found') unless learner

    @dataservice_bucket_logger = Dataservice::BucketLogger.where(learner_id: learner.id).first_or_create
    bundle = "[" + @dataservice_bucket_logger.bucket_log_items.map{|li| li.content }.join(",") + "]"

    respond_to do |format|
      # format.html # show.html.erb
      format.bundle {
        send_data(
          bundle,
          :type => 'application/octet-stream',
          :filename => "data-logs-#{@dataservice_bucket_logger.id}.dat",
          :disposition => 'inline'
        )
      }
    end
  end

  def show_log_items_by_name
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Dataservice::BucketLogger
    # authorize @bucket_logger
    # authorize Dataservice::BucketLogger, :new_or_create?
    # authorize @bucket_logger, :update_edit_or_destroy?
    @dataservice_bucket_logger = Dataservice::BucketLogger.find_by_name(params[:name])
    raise ActionController::RoutingError.new('Not Found') unless @dataservice_bucket_logger

    bundle = "[" + @dataservice_bucket_logger.bucket_log_items.map{|li| li.content }.join(",") + "]"

    respond_to do |format|
      # format.html # show.html.erb
      format.bundle {
        send_data(
          bundle,
          :type => 'application/octet-stream',
          :filename => "data-logs-#{@dataservice_bucket_logger.id}.dat",
          :disposition => 'inline'
        )
      }
    end
  end
end
