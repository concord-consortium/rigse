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
     expect(activity_feedback.activity).to eq(activity)
    end

    it "should have an offering" do
      expect(activity_feedback.portal_offering).to eq(offering)
    end

    it "the defaults" do
      expect(activity_feedback.enable_text_feedback).to eq(false)
      expect(activity_feedback.max_score).to eq(10)
      expect(activity_feedback.score_type).to eq(Portal::OfferingActivityFeedback::SCORE_NONE)
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
        expect(activity_feedback.max_score).to eq(12)
      end
      it "should be using manual scoring" do
        expect(activity_feedback.score_type).to eq(Portal::OfferingActivityFeedback::SCORE_MANUAL)
      end
      it "should be using text feedback" do
        expect(activity_feedback.enable_text_feedback).to eq(true)
      end

      describe "turning off text feedback" do
        before(:each) do
          activity_feedback.set_feedback_options({enable_text_feedback: false})
        end
        subject { activity_feedback.reload }

        describe '#enable_text_feedback' do
          subject { super().enable_text_feedback }
          it { is_expected.to be false }
        end

        describe '#max_score' do
          subject { super().max_score }
          it {is_expected.to be 12 }
        end
      end
    end
  end
end