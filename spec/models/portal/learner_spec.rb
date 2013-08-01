require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Learner do
  let(:student)        { mock_model(Portal::Student)     }
  let(:offering)       { mock_model(Portal::Offering)    }
  let(:report_learner) { mock_model(Report::Learner,
    :[]= => nil,
    :save => true,
    :update_fields => true)
  }
  let(:attributes)  do
    {
      :student        => student,
      :offering       => offering,
      :report_learner => report_learner
    }
  end
  subject           { Portal::Learner.create!(attributes) }

  describe "a bare instance" do
    it "should be valid" do
      subject.should be_valid
    end
  end

  describe "associated lightweight blobs used to store images &etc." do
    it "should return lightweight blobs when they already exist" do
      blob = Dataservice::Blob.create(:learner_id => subject.id)
      subject.reload
      subject.lightweight_blobs.should include(blob)
    end
    it "should return an empty set when no blobs exist" do
      subject.lightweight_blobs.should be_empty
    end
    it "should allow for creating a new blob" do
      subject.lightweight_blobs.create
      subject.lightweight_blobs.should_not be_empty
    end
  end
end