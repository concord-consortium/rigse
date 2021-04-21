require 'spec_helper'

describe "Dataservice Buckets" do
  before :each do
    # set up a learner
    student = FactoryBot.create(:portal_student)
    offering = FactoryBot.create(:portal_offering)
    @learner = FactoryBot.create(:portal_learner, :student => student, :offering => offering)
  end

  it 'should deliver empty bucket data when no bucket contents exist' do
    get "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_contents.bundle"

    expect(response.body).to eq("")
  end

  it 'should deliver the most recent bucket contents when more than one contents exist' do
    log = Dataservice::BucketLogger.where(learner_id: @learner.id).first_or_create
    Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body1")
    Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body4")
    Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body3")
    get "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_contents.bundle"

    expect(response.body).to eq("body3")
  end

  it 'should deliver bucket contents by logger id' do
    log = Dataservice::BucketLogger.where(learner_id: @learner.id).first_or_create
    Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body1")
    Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body4")
    get "/dataservice/bucket_loggers/#{log.id}.bundle"

    expect(response.body).to eq("body4")
  end

  it 'should accept posted bundle contents by logger id' do
    log = Dataservice::BucketLogger.where(learner_id: @learner.id).first_or_create
    post "/dataservice/bucket_loggers/#{log.id}/bucket_contents.bundle", params: "This is some content"

    @learner.reload
    expect(@learner.bucket_logger.most_recent_content).to eq("This is some content")
  end

  it 'should accept posted bundle contents by learner id' do
    post "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_contents.bundle", params: "This is some content"

    @learner.reload
    expect(@learner.bucket_logger.most_recent_content).to eq("This is some content")
  end

  it 'should accept multiple posted bundle contents by logger id' do
    post "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_contents.bundle", params: "This is some content"
    post "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_contents.bundle", params: "This is some content 2"
    post "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_contents.bundle", params: "This is some content 3"
    post "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_contents.bundle", params: "This is totally different content"

    @learner.reload
    expect(@learner.bucket_logger.most_recent_content).to eq("This is totally different content")
  end

  it 'should accept multiple posted items by logger id and return them all' do
    post "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_log_items.bundle", params: "This is some content"
    post "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_log_items.bundle", params: "This is some content 2"

    get "/dataservice/bucket_loggers/learner/#{@learner.id}/bucket_log_items.bundle"
    expect(response.body).to eq("[This is some content,This is some content 2]")
  end

  ### BucketLoggers with no learners ###
  describe "with no learners" do
    it 'should raise an error when no bucket contents exist' do
      expect {get "/dataservice/bucket_loggers/name/unknownBucketName/bucket_contents.bundle"}.to raise_error(ActionController::RoutingError)
    end

    it 'should deliver the most recent bucket contents when more than one contents exist' do
      log = Dataservice::BucketLogger.where(name: 'myBucket').first_or_create
      Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body1")
      Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body4")
      Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body3")
      get "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle"

      expect(response.body).to eq("body3")
    end

    it 'should deliver bucket contents by logger id' do
      log = Dataservice::BucketLogger.where(name: 'myBucket').first_or_create
      Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body1")
      Dataservice::BucketContent.create(:bucket_logger_id => log.id, :processed => true, :empty => false, :body => "body4")
      get "/dataservice/bucket_loggers/#{log.id}.bundle"

      expect(response.body).to eq("body4")
    end

    it 'should accept posted bundle contents by arbitrary names' do
      post "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle", params: "This is some content"
      get "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle"

      expect(response.body).to eq("This is some content")
    end

    it 'should accept multiple posted bundle contents by arbitrary names' do
      post "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle", params: "This is some content"
      post "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle", params: "This is some content 2"
      post "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle", params: "This is some content 3"
      post "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle", params: "This is totally different content"
      get "/dataservice/bucket_loggers/name/myBucket/bucket_contents.bundle"

      expect(response.body).to eq("This is totally different content")
    end

    it 'should accept multiple posted items by name and return them all' do
      post "/dataservice/bucket_loggers/name/myBucket/bucket_log_items.bundle", params: "This is some content"
      post "/dataservice/bucket_loggers/name/myBucket/bucket_log_items.bundle", params: "This is some content 2"

      get "/dataservice/bucket_loggers/name/myBucket/bucket_log_items.bundle"
      expect(response.body).to eq("[This is some content,This is some content 2]")
    end
  end
end
