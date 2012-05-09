class Dataservice::PeriodicBundleContentsMetalController < ActionController::Metal

  def create
    bundle_content = nil
    if bundle_logger = Dataservice::PeriodicBundleLogger.find(params[:id])
      body = request.body.read
      bundle_content = Dataservice::PeriodicBundleContent.create(:periodic_bundle_logger_id => bundle_logger.id, :body => body)
    end
    if bundle_content
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
