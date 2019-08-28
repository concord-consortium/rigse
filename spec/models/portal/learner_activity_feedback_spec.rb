require File.expand_path('../../../spec_helper', __FILE__)

testClazz = Portal::LearnerActivityFeedback

describe Portal::LearnerActivityFeedback do
  let(:activity)            { FactoryBot.create(:activity)}
  let(:activities)          { [ activity ] }
  let(:runnable)            { FactoryBot.create(:investigation, {activities: activities}) }
  let(:args)                { {runnable: runnable} }
  let(:offering)            { FactoryBot.create(:portal_offering, args) }
  let(:off_feedback_params) { {activity:activity, portal_offering: offering } }
  let(:activity_feedback)   { Portal::OfferingActivityFeedback.create(off_feedback_params) }

  let(:learner) { FactoryBot.create(:full_portal_learner, {offering:offering}) }

  let(:feedback_params)  { {portal_learner: learner, activity_feedback: activity_feedback} }
  let(:learner_feedback) { Portal::LearnerActivityFeedback.create(feedback_params)         }

  describe "learner_feedback" do
    it "should have an activity_feedback" do
      expect(learner_feedback.activity_feedback).to eq(activity_feedback)
    end
  end

  describe "the activity feedback" do
    it "should know about this learner feedback" do
      expect(activity_feedback.learner_activity_feedbacks).to include(learner_feedback)
    end
  end

  describe "for_learner_and_activity_feedback" do
    it "should return an array including our learner feedback" do
      ours = learner_feedback
      found = Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner.id, activity_feedback.id)
      expect(found).to include(ours)
    end
  end

  # TODO: auto-generated
  describe '.for_learner_and_activity_feedback' do
    it 'for_learner_and_activity_feedback' do
      result = described_class.for_learner_and_activity_feedback(learner.id, activity_feedback.id)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.open_feedback_for' do
    it 'open_feedback_for' do
      result = described_class.open_feedback_for(learner, activity_feedback)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.update_feedback' do
    it 'update_feedback' do
      attributes = {}
      result = described_class.update_feedback(learner.id, activity_feedback.id, attributes)

      expect(result).not_to be_nil
    end
  end


end
