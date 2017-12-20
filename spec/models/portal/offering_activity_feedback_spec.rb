require File.expand_path('../../../spec_helper', __FILE__)

testClazz = Portal::OfferingActivityFeedback

describe Portal::OfferingActivityFeedback do
  describe "Creation" do
    let(:activity)         { Factory.create(:activity)}
    let(:activities)       { [activity] }
    let(:runnable)         { Factory.create(:investigation, {activities: activities}) }
    let(:args)             { {runnable: runnable} }
    let(:offering)         { Factory.create(:portal_offering, args) }
    let(:feedback_params)  { {activity: activity, portal_offering: offering} }
    let(:activity_feedback){ Portal::OfferingActivityFeedback.create(feedback_params) }

    it "should have an activity" do
     activity_feedback.activity.should == activity
    end

    it "should have an offering" do
      activity_feedback.portal_offering.should == offering
    end

    it "the defaults" do
      activity_feedback.enable_text_feedback.should == false
      activity_feedback.max_score.should == 10
      activity_feedback.score_type.should == Portal::OfferingActivityFeedback::SCORE_NONE
    end

    describe "#set_feedback_options" do
      let(:options) do
        {
          max_score: 12,
          score_type: Portal::OfferingActivityFeedback::SCORE_MANUAL,
          enable_text_feedback: true
        }
      end
      before(:each) do
        activity_feedback.set_feedback_options(options)
      end
      it "should have a max score of 12" do
        activity_feedback.max_score.should == 12
      end
      it "should be using manual scoring" do
        activity_feedback.score_type.should == Portal::OfferingActivityFeedback::SCORE_MANUAL
      end
      it "should be using text feedback" do
        activity_feedback.enable_text_feedback.should == true
      end

      describe "turning off text feedback" do
        before(:each) do
          activity_feedback.set_feedback_options({enable_text_feedback: false})
        end
        subject { activity_feedback.reload }
        its(:enable_text_feedback) { should be false }
        its(:max_score) {should be 12 }
      end
    end
  end
end