# encoding: utf-8
require 'spec_helper'

describe API::V1::Report do
  let(:offering)          { FactoryGirl.create(:portal_offering) }


  describe "class methods" do
    # def self.update_feedback_settings(offering, embeddable, feedback_settings)
    describe "update_feedback_settings" do
      let(:enable_score)      { nil }
      let(:enable_feedback)   { nil }
      let(:max_score)         { nil }
      let(:feedback_settings) do
        {
            'enable_score' => enable_score,
            'enable_text_feedback' => enable_feedback,
            'max_score' => max_score,
            'embeddable_key' => API::V1::Report.embeddable_key(embeddable)
        }
      end

      let(:embeddable) { FactoryGirl.create(:open_response) }
      let(:meta_data)  { Portal:: OfferingEmbeddableMetadata.find_by_offering_id_and_embeddable_id_and_embeddable_type(offering.id, embeddable.id, embeddable.class.name) }

      before(:each) do
        API::V1::Report.update_feedback_settings(offering, feedback_settings )
      end

      describe "setting enable_score, enable_feedback, and max_score of 10" do
        subject { meta_data }
        let(:enable_score)         { true }
        let(:enable_feedback)      { true }
        let(:max_score)            { 10   }

        its(:max_score)            { should be 10 }
        its(:enable_text_feedback) { should be true }
        its(:enable_score)         { should be true }

        describe "changing the max_score to 0" do
          let(:max_score)            { 0 }

          its(:max_score)            { should be 0 }
          its(:enable_text_feedback) { should be true }
          its(:enable_score)         { should be true }
        end

        describe "disabling text feedback" do
          let(:enable_feedback)      { false }

          its(:max_score)            { should be 10 }
          its(:enable_text_feedback) { should be false }
          its(:enable_score)         { should be true  }
        end
      end

    end
    describe "updating feedback on an answer" do
      let(:score)                { nil }
      let(:text_feedback)        { nil }
      let(:has_been_reviewed)    { nil }
      let(:open_response)        { FactoryGirl.create(:open_response) }
      let(:learner)              { FactoryGirl.create(:full_portal_learner) }
      let(:open_response_answer) { Saveable::OpenResponse.create(open_response: open_response, learner: learner)}
      let(:answer_key)           { API::V1::Report.encode_answer_key(open_response_answer) }
      let(:feedback) do
        {
            'answer_key' => answer_key,
            'score'      => score,
            'feedback'   => text_feedback,
            'has_been_reviewed' => has_been_reviewed
        }
      end
      before(:each) do
        API::V1::Report.submit_feedback(feedback)
      end

      describe "when no feedback or answer has been given yet" do
        it "should indicate that it doesn't need review" do
          open_response_answer.needs_review?.should be_false
        end
      end

      describe "when an answer is given" do
        before(:each) do
          open_response_answer.answers.create(answer: "this is the answer")
          API::V1::Report.submit_feedback(feedback)
        end

        it "should indicate that it does need a review" do
          open_response_answer.needs_review?.should be_true
        end

        describe 'giving feedback without marking complete' do
          let(:text_feedback)  { "good job" }
          let(:score)          {  10        }

          it "should indicate that it does need a review" do
            open_response_answer.needs_review?.should be_true
          end

          it "should have the correct score" do
            open_response_answer.current_score.should eq score
          end

          it "should have the correct feedback" do
            open_response_answer.current_feedback.should eq text_feedback
          end
        end


        describe "marking the feedback complete" do
          let(:text_feedback)     { "good job!" }
          let(:score)             { 20          }
          let(:has_been_reviewed) { true        }

          it "should show that feedback is complete" do
            open_response_answer.needs_review?.should be_false
          end

          it "should have the correct score" do
            open_response_answer.current_score.should eq score
          end

          it "should have the correct feedback" do
            open_response_answer.current_feedback.should eq text_feedback
          end
        end

      end
    end
  end
end