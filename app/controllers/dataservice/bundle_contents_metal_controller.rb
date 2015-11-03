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

      # make a time object out of X-Queue-Start header if it exists
      upload_time = nil
      x_queue_start = request.headers['X-Queue-Start']
      if x_queue_start
        usecs_since_1970 = x_queue_start.match(/t=(\d+)/)[1].to_i
        upload_time = Time.now - Time.at(usecs_since_1970/1000000)
      end
      bundle_logger.end_bundle( { :body => body, :upload_time => upload_time } )
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
