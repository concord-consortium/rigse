require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Learner do
  let(:student)        { mock_model(Portal::Student)     }
  let(:offering)       { FactoryBot.create(:portal_offering)   }
  let(:report_learner) { mock_model(Report::Learner,
    :[]= => nil,
    :save => true,
    :update_fields => true
  )}
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

  describe '#answered' do
    it 'answered for open responses' do
      result = subject.open_responses.answered

      expect(result).to be_empty
    end
  end

  describe '#answered' do
    it 'answered for image_questions' do
      result = subject.image_questions.answered

      expect(result).to be_empty
    end
  end

  describe '#answered' do
    it 'answered for external_links' do
      result = subject.external_links.answered

      expect(result).to be_empty
    end
  end

  describe '#answered' do
    it 'answered for interactives' do
      result = subject.interactives.answered

      expect(result).to be_empty
    end
  end

  describe '#answered' do
    it 'answered for multiple_choices' do
      result = subject.multiple_choices.answered

      expect(result).to be_empty
    end
  end

  describe '#answered_correctly' do
    it 'answered for multiple_choices' do
      result = subject.multiple_choices.answered_correctly

      expect(result).to be_empty
    end
  end

  describe '#sessions' do
    it 'sessions' do
      result = subject.sessions

      expect(result).not_to be_nil
    end
  end

  describe '#valid_loggers?' do
    it 'valid_loggers?' do
      result = subject.valid_loggers?

      expect(result).not_to be_nil
    end
  end

  describe '#create_new_loggers' do
    it 'create_new_loggers' do
      result = subject.create_new_loggers

      expect(result).not_to be_nil
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

  describe '#saveable_count' do
    it 'saveable_count' do
      result = subject.saveable_count

      expect(result).not_to be_nil
    end
  end

  describe '#saveable_answered' do
    it 'saveable_answered' do
      result = subject.saveable_answered

      expect(result).not_to be_nil
    end
  end
end
