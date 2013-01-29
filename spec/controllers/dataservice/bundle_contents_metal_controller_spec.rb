require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContentsMetalController do
  describe "POST create" do
  	before :each do
      @mock_bundle_logger = mock_model(Dataservice::BundleLogger)
      Dataservice::BundleLogger.should_receive(:find).with("37").and_return(@mock_bundle_logger)
      @mock_bundle_content = mock_model(Dataservice::BundleContent)
      @mock_bundle_logger.should_receive(:in_progress_bundle).twice.and_return(@mock_bundle_content)
      Dataservice::LaunchProcessEvent.should_receive(:create)
      @mock_bundle_logger.should_receive(:bundle_contents).and_return([@mock_bundle_content])
      @mock_bundle_content.should_receive(:created_at).and_return(Time.now)
      login_admin
  	end

    it "ends the bundle with the body of the post" do
      body_content = "body content of bundle"
      @mock_bundle_logger.should_receive(:end_bundle).with({:body => body_content , :upload_time => nil })
      @request.env['RAW_POST_DATA'] = body_content
      post :create, id: 37
    end

    it "records upload time if X-Queue-Start header is set" do
      body_content = "body content of bundle"

      @mock_bundle_logger.should_receive(:end_bundle).with({:body => body_content , :upload_time => be_within(1).of(21) })
      @request.env['RAW_POST_DATA'] = body_content
      # set a start of 20 seconds before now
      @request.env['X-Queue-Start'] = "t=#{((Time.now - 20).to_f*1000000).to_i}"
      post :create, id: 37
    end
  end
end
