class MiscController < ActionController::Base
  # This controller is intended for things that don't need all of the
  # complex setup that happens in ApplicationController. If you have
  # actions that don't need things like authentication, current_visitor,
  # etc. then you can place them here and they will execute more
  # quickly.
  # Also notably, nothing in the chain before this accesses session[],
  # so if a session does not already exist *it will not be created*
  # unless you action accesses session[].

  def banner
    learner = (params[:learner_id] ? Portal::Learner.find(params[:learner_id]) : nil)
    if learner && learner.bundle_logger.in_progress_bundle
      launch_event = Dataservice::LaunchProcessEvent.create(
        :event_type => Dataservice::LaunchProcessEvent::TYPES[:logo_image_requested],
        :event_details => "Activity launch started. Waiting for configuration...",
        :bundle_content => learner.bundle_logger.in_progress_bundle
      )
    end
    asset = ActionController::Base.helpers.asset_paths.asset_for("cc_corner_logo.png", nil)
    send_file(asset.pathname.to_s, {:type => 'image/png', :disposition => 'inline'} )
  end

  def installer_report
    body = request.body.read
    remote_ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    success = !!(body =~ /Succeeded! Saved and loaded jar./)
    report = InstallerReport.create(:body => body, :remote_ip => remote_ip, :success => success, 
      :jnlp_session_id => params[:jnlp_session_id])
    render :xml => "<created/>", :status => :created
  end

  def stats
    stats = {}
    stats[:teachers] = Portal::Teacher.count
    stats[:students] = Portal::Student.count
    stats[:classes] = Portal::Clazz.count
    stats[:users] = User.count
    stats[:learners] = Portal::Learner.count
    stats[:offerings] = Portal::Offering.count
    stats[:bundle_loggers] = Dataservice::BundleLogger.count
    stats[:bundle_contents] = Dataservice::BundleContent.count
    stats[:investigations] = Investigation.count
    stats[:activities] = Activity.count
    stats[:sections] = Section.count
    stats[:pages] = Page.count
    stats[:external_activities] = ExternalActivity.count
    stats[:resource_pages] = ResourcePage.count

    # this sql was created because using the active record query language didn't generate the correct distinct ordering
    # additionally it allows us to get all the 'active' stats in one shot
    result = ActiveRecord::Base.connection.select_one(
      "SELECT COUNT(DISTINCT portal_clazzes.id) AS active_classes, " +
      "COUNT(DISTINCT portal_learners.id) AS active_learners, " +
      "COUNT(DISTINCT portal_learners.student_id) AS active_students, " +
      "COUNT(DISTINCT portal_offerings.runnable_id, portal_offerings.runnable_type) AS active_runnables, " +
      "COUNT(DISTINCT portal_teachers.id) AS active_teachers " +
      "FROM portal_teachers " +
      "INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.teacher_id = portal_teachers.id " +
      "INNER JOIN portal_clazzes ON portal_clazzes.id = portal_teacher_clazzes.clazz_id " +
      "INNER JOIN portal_offerings ON portal_offerings.clazz_id = portal_clazzes.id " +
      "INNER JOIN portal_learners ON portal_learners.offering_id = portal_offerings.id " +
      "INNER JOIN dataservice_bundle_loggers ON dataservice_bundle_loggers.id = portal_learners.bundle_logger_id " +
      "INNER JOIN dataservice_bundle_contents ON dataservice_bundle_contents.bundle_logger_id = dataservice_bundle_loggers.id"
      )
    stats.merge!(result)

    respond_to do |format|
      format.json do
        render :json => stats
      end
    end
  end

  private

  def get_banner_asset(name)
    ActionController::Base.helpers.asset_paths.asset_for("new/banners/#{name}.png", nil)
  end

end
