class Dataservice::ConsoleContentsMetalController < ActionController::Metal

  def create
    console_content = nil
    if console_logger = Dataservice::ConsoleLogger.find(params[:id])
      body = request.body.read
      console_content = console_logger.console_contents.create(:body => body)
    end
    if console_content
      digest = Digest::MD5.hexdigest(body)

      self.status = 201
      self.content_type = 'text/xml'
      self.response_body = ''
      self.headers['Last-Modified'] = console_content.created_at.httpdate
      self.headers['Content-Length'] = '0'
      self.headers['Content-MD5'] = digest
    else
      self.status = 404
      self.content_type = 'text/html'
      self.response_body = 'Not Found'
    end
  end

end
