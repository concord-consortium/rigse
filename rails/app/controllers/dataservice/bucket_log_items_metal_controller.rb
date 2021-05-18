class Dataservice::BucketLogItemsMetalController < ActionController::Metal

  def create
    create_with_logger(Dataservice::BucketLogger.find(params[:id]))
  end

  def create_by_learner
    learner = Portal::Learner.find(params[:id]) rescue nil
    bucket_logger = learner ? Dataservice::BucketLogger.where(learner_id: learner.id).first_or_create : nil
    create_with_logger(bucket_logger)
  end

  def create_by_name
    bucket_logger = Dataservice::BucketLogger.where(name: params[:name]).first_or_create
    create_with_logger(bucket_logger)
  end

  private

  def create_with_logger(bucket_logger)
    bucket_content = nil
    if bucket_logger
      body = request.body.read
      # also set processed and empty for now
      bucket_content = Dataservice::BucketLogItem.create(
        :bucket_logger_id => bucket_logger.id,
        :content => body
      )
    end
    if bucket_content
      digest = Digest::MD5.hexdigest(body)

      self.status = 201
      self.media_type = 'text/xml'
      self.response_body = ''
      self.headers['Last-Modified'] = bucket_content.created_at.httpdate
      self.headers['Content-Length'] = '0'
      self.headers['Content-MD5'] = digest
    else
      self.status = 404
      self.media_type = 'text/html'
      self.response_body = 'Not Found'
    end
  end
end
