require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Learner do
  let(:learner)          { FactoryBot.create(:full_portal_learner) }
  subject                { learner }

  describe "a bare instance" do
    it "should be valid" do
      expect(subject).to be_valid
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
