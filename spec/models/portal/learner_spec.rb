require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Learner do
  let(:student)        { mock_model(Portal::Student)     }
  let(:offering)       { mock_model(Portal::Offering)    }
  let(:report_learner) { mock_model(Report::Learner,
    :[]= => nil,
    :save => true,
    :update_fields => true,
    # this is needed because of the inverse_of definition in the report_learner associtation
    # I think newer version of mock_model take care of this for you
    :association => double(:target= => nil) )
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
end