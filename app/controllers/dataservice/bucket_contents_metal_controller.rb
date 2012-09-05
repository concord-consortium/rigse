class Dataservice::BucketContentsMetalController < ActionController::Metal

  def create
    create_with_logger(Dataservice::BucketLogger.find(params[:id]))
  end

  def create_by_learner
    bucket_logger = Dataservice::BucketLogger.find_or_create_by_learner_id(params[:id])
    create_with_logger(bucket_logger)
  end

  private

  def create_with_logger(bucket_logger)
    bucket_content = nil
    if bucket_logger
      body = request.body.read
      # also set processed and empty for now
      bucket_content = Dataservice::BucketContent.create(
        :bucket_logger_id => bucket_logger.id,
        :body => body,
        :processed => true,
        :empty => (body.nil? || body.empty?)
      )
    end
    if bucket_content
      digest = Digest::MD5.hexdigest(body)

      self.status = 201
      self.content_type = 'text/xml'
      self.response_body = ''
      self.headers['Last-Modified'] = bucket_content.created_at.httpdate
      self.headers['Content-Length'] = '0'
      self.headers['Content-MD5'] = digest
    else
      self.status = 404
      self.content_type = 'text/html'
      self.response_body = 'Not Found'
    end
  end

end
