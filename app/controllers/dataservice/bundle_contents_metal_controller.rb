class Dataservice::BundleContentsMetalController < ActionController::Metal

  def create
    if bundle_logger = Dataservice::BundleLogger.find(params[:id])
      body = request.body.read
      if bundle_logger.in_progress_bundle
        launch_event = ::Dataservice::LaunchProcessEvent.create(
          :event_type => ::Dataservice::LaunchProcessEvent::TYPES[:bundle_saved],
          :event_details => "Learner session data saved. Activity should now be closed.",
          :bundle_content => bundle_logger.in_progress_bundle
        )
      end
      bundle_logger.end_bundle( { :body => body } )
      bundle_content = bundle_logger.bundle_contents.last
      digest = Digest::MD5.hexdigest(body)

      self.status = 201
      self.content_type = 'text/xml'
      self.response_body = ''
      self.headers['Last-Modified'] = bundle_content.created_at.httpdate
      self.headers['Content-Length'] = '0'
      self.headers['Content-MD5'] = digest
    else
      self.status = 404
      self.content_type = 'text/html'
      self.response_body = 'Not Found'
    end
  end

end
