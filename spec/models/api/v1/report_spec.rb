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
      let(:meta_data)  { Portal::OfferingEmbeddableMetadata.find_by_offering_id_and_embeddable_id_and_embeddable_type(offering.id, embeddable.id, embeddable.class.name) }

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
            open_response_answer.answers.length.should have_at_least(1).answer
            open_response_answer.current_score.should eq score
          end

          it "should have the correct feedback" do
            open_response_answer.current_feedback.should eq text_feedback
          end
        end
      end
    end

    describe "#page_json" do
      let(:url)    { "http//unlikely.com/foo/bar" }
      let(:page)   { FactoryGirl.create(:page, url: url, name: "page 1") }
      let(:report) { API::V1::Report.new(offering: offering)             }
      let(:json)   { report.page_json(page,answers) }
      let(:answers){ [] }
      it "should return json" do
        expect(json).to include(url: url)
        expect(json).to include(name: "page 1")

      end
    end

    describe "activity level feedback" do
      let(:url)              { "http//unlikely.com/foo/bar" }
      let(:activity)         { FactoryGirl.create(:activity) }
      let(:learner)          { FactoryGirl.create(:full_portal_learner, {offering:offering}) }
      let(:student)          { learner.student }
      let(:learner_feedback) { Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner, activity_feedback) }
      let(:activity_feedback){ Portal::OfferingActivityFeedback.for_offering_and_activity(offering, activity) }
      let(:feedback_id)      { activity_feedback.id }
      let(:learner_id)       { learner.id }
      let(:report)           { API::V1::Report.new(offering: offering) }
      let(:json)             { report.activity_json(activity, []) }
      let(:feedback_params)  { {} }
      before(:each) do
        offering.runnable.activities << activity
        activity_feedback.set_feedback_options(feedback_params)
      end

      describe "without any student feedback" do
        it "should return json without feedback" do
          expect(json).to include(activity_feedback: [])
        end

        describe "the default configuration (no feedback)" do
          it "should have json like this" do
            expect(json).to include(enable_text_feedback: false)
            expect(json).to include(score_type: "none")
            expect(json).to include(max_score: 10)
          end
        end

        describe "when configured to have an automatic score and text feedback" do
          let(:feedback_params) { {enable_text_feedback: true, score_type: "auto", max_score: 20} }
          it "should have json like this" do
            expect(json).to include(enable_text_feedback: true)
            expect(json).to include(score_type: "auto")
            expect(json).to include(max_score: 20)
          end
        end
      end

      describe "with some student feedback" do
        let(:score)            { 5 }
        let(:text_feedback)    { "good work" }
        let(:has_been_reviewed){ true }

        before(:each) do
          # create some old feedback
          Delorean.time_travel_to("1 month ago") do
            Portal::LearnerActivityFeedback.update_feedback(
              learner,
              activity_feedback,
              { score: 4, text_feedback: text_feedback, has_been_reviewed: false  }
            )
            Portal::LearnerActivityFeedback.update_feedback(
              learner,
              activity_feedback,
              { score: 5, text_feedback: text_feedback, has_been_reviewed: true }
            )
          end
        end

        it "should return json including only one updated feedback for student" do
          feedback = json[:activity_feedback].first
          expect(feedback).to include({:student_id => student.id})
          expect(feedback).to include({:learner_id => learner.id})
          expect(feedback[:feedbacks].length).to eql(1)
          expect(feedback[:feedbacks].first).to include({:score => 5})
          expect(feedback[:feedbacks].first).to include({:feedback => "good work"})
          expect(feedback[:feedbacks].first).to include({:has_been_reviewed => true})
        end

        describe "adding more feedback" do
          before(:each) do
            Portal::LearnerActivityFeedback.update_feedback(
              learner,
              activity_feedback,
              { score: 7, text_feedback: text_feedback, has_been_reviewed: true }
            )
          end

          it "should have two feedback records" do
            feedback = json[:activity_feedback].first
            expect(feedback[:feedbacks].length).to eql(2)
            expect(feedback[:feedbacks].first).to include({:score => 7})
          end
        end
      end

      describe "update activity feedback_settings using the API" do
        let(:enable_text_feedback)   { nil }
        let(:score_type)             { "none" }
        let(:max_score)              { nil }
        let(:feedback_settings) do
          {
              'activity_feedback_id' => feedback_id,
              'learner_id' => learner_id,
              'max_score' => max_score,
              'score_type' => score_type,
              'enable_text_feedback' => enable_text_feedback
          }
        end

        before(:each) do
          API::V1::Report.update_activity_feedback_settings(feedback_settings)
          activity_feedback.reload
        end

        describe "setting automatic score, enable_feedback, and max_score of 12" do
          subject { activity_feedback }
          let(:score_type)           { "manual" }
          let(:max_score)            { 12 }
          let(:enable_text_feedback) { true }

          its(:max_score)            { should eq 12 }
          its(:score_type)           { should eq "manual" }
          its(:enable_text_feedback) { should eq true }

          describe "changing the max_score to 0" do
            let(:max_score)            { 0 }

            its(:max_score)            { should eq 0 }
            its(:enable_text_feedback) { should eq true }
            its(:score_type)           { should eq "manual"}
          end

          describe "enabling auto scoring" do
            let(:score_type)           { "auto" }

            its(:max_score)            { should eq 12 }
            its(:enable_text_feedback) { should be true }
            its(:score_type)           { should eq "auto"  }
          end
        end
      end

      describe "updating activity feedback for a learner using the API" do
        let(:score)                { nil }
        let(:text_feedback)        { nil }
        let(:has_been_reviewed)    { nil }
        let(:feedback) do
          {
              'learner_id'           => learner_id,
              'activity_feedback_id' => feedback_id,
              'score'                => score,
              'text_feedback'        => text_feedback,
              'has_been_reviewed'    => has_been_reviewed
          }
        end

        before(:each) do
          API::V1::Report.submit_activity_feedback(feedback)
        end

        describe "giving activity level feedback feedback" do
          let(:learner_feedback) { Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner, activity_feedback)}
          describe 'giving feedback without marking complete' do
            let(:text_feedback) { "good job" }
            let(:score)         {  10        }
            subject             { learner_feedback.first }

            its(:score)         { should eql 10 }
            its(:text_feedback) { should eql "good job" }
          end

          describe "marking feedback complete" do
            subject                 { learner_feedback.first }
            let(:has_been_reviewed) { true }
            let(:score)             { 10   }

            its(:has_been_reviewed) { should be true }

            it "Should create a subsequent entry in the list of feedbacks on next update." do
              learner_feedback.should have(1).feedback
              a = API::V1::Report.submit_activity_feedback({
                "score"                => 11,
                "has_been_reviewed"    => true,
                "learner_id"           => learner_id,
                "activity_feedback_id" => feedback_id
              })
              new_feedback = Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner, activity_feedback)
              new_feedback.should have(2).feedbacks
            end
          end
        end
      end
    end

  end

end