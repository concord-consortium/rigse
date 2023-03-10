require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Learner do
  let(:learner)          { FactoryBot.create(:full_portal_learner) }
  subject                { learner }

  describe "a bare instance" do
    it "should be valid" do
      expect(subject).to be_valid
    end
  end

  describe "associated lightweight blobs used to store images &etc." do
    it "should return lightweight blobs when they already exist" do
      blob = Dataservice::Blob.create(:learner_id => subject.id)
      subject.reload
      expect(subject.lightweight_blobs).to include(blob)
    end
    it "should return an empty set when no blobs exist" do
      expect(subject.lightweight_blobs).to be_empty
    end
    it "should allow for creating a new blob" do
      subject.lightweight_blobs.create
      expect(subject.lightweight_blobs).not_to be_empty
    end
  end

  describe '#user' do
    xit 'user' do
      result = subject.user

      expect(result).not_to be_nil
    end
  end

  describe '#name' do
    xit 'name' do
      result = subject.name

      expect(result).not_to be_nil
    end
  end

  describe '#run_format' do
    xit 'run_format' do
      result = subject.run_format

      expect(result).not_to be_nil
    end
  end

  describe "update_report_model_cache" do
    it "should call the ElasticSearch API with the approriate data" do
      WebMock::RequestRegistry.instance.reset!

      # by calling `subject` we trigger the Create method to be called for this test
      subject

      assert_requested(:post, /report_learners\/doc/,
        times: 1) { |req|
          req.headers == {'Content-Type' => 'application/json'}
          body = JSON.parse(req.body)
          body["doc"] != nil
          body["doc"]["learner_id"].is_a? Integer
          body["doc"]["student_id"].is_a? Integer
          body["doc"]["user_id"].is_a? Integer
          body["doc"]["offering_name"] =~ /test investigation/
          body["doc_as_upsert"] == true
      }
    end
  end

  describe '#update_last_run' do
    it 'should modify the last_run with the current time' do
      now = Time.now
      max_delta_seconds = 2
      subject.update_last_run
      elapsed_seconds = subject.last_run - now
      expect(elapsed_seconds).to be < max_delta_seconds
    end
  end
end
