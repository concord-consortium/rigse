require File.expand_path('../../../spec_helper', __FILE__)

testClazz = Portal::LearnerActivityFeedback

describe Portal::LearnerActivityFeedback do
  let(:activity)            { Factory.create(:activity)}
  let(:activities)          { [ activity ] }
  let(:runnable)            { Factory.create(:investigation, {activities: activities}) }
  let(:args)                { {runnable: runnable} }
  let(:offering)            { Factory.create(:portal_offering, args) }
  let(:off_feedback_params) { {activity:activity, portal_offering: offering } }
  let(:activity_feedback)   { Portal::OfferingActivityFeedback.create(off_feedback_params) }

  let(:learner) { Factory.create(:full_portal_learner, {offering:offering}) }

  let(:feedback_params)  { {portal_learner: learner, activity_feedback: activity_feedback} }
  let(:learner_feedback) { Portal::LearnerActivityFeedback.create(feedback_params)         }

  describe "learner_feedback" do
    it "should have an activity_feedback" do
      learner_feedback.activity_feedback.should == activity_feedback
    end
  end

  describe "the activity feedback" do
    it "should know about this learner feedback" do
      activity_feedback.learner_activity_feedbacks.should include(learner_feedback)
    end
  end

  describe "for_learner_and_activity_feedback" do
    it "should return an array including our learner feedback" do
      ours = learner_feedback
      found = Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner,activity_feedback)
      found.should include(ours)
    end
  end

end