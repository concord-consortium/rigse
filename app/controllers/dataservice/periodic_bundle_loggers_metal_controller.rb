class Dataservice::PeriodicBundleLoggersMetalController < ActionController::Metal

  def session_end_notification
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Dataservice::PeriodicBundleLoggersMetal
    # authorize @periodic_bundle_loggers_metal
    # authorize Dataservice::PeriodicBundleLoggersMetal, :new_or_create?
    # authorize @periodic_bundle_loggers_metal, :update_edit_or_destroy?
    if pbl = Dataservice::PeriodicBundleLogger.find(params[:id])
      if ipb = pbl.learner.bundle_logger.in_progress_bundle
        launch_event = ::Dataservice::LaunchProcessEvent.create(
          :event_type => ::Dataservice::LaunchProcessEvent::TYPES[:bundle_saved],
          :event_details => "Learner session data saved. Activity should now be closed.",
          :bundle_content => ipb
        )
        pbl.learner.bundle_logger.end_bundle( { :body => "" } )
      end
      self.status = 201
      self.content_type = 'text/xml'
      self.response_body = '<ok/>'
    else
      self.status = 404
      self.content_type = 'text/html'
      self.response_body = 'Not Found'
    end
  end

end
