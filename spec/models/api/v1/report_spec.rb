# encoding: utf-8
require 'spec_helper'

describe API::V1::Report do
  let(:investigation)      { FactoryBot.create(:investigation) }
  let(:external_activity)  { FactoryBot.create(:external_activity, template: investigation) }
  let(:runnable)           { investigation }
  let(:offering)           { FactoryBot.create(:portal_offering, runnable: runnable) }

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

      let(:embeddable) { FactoryBot.create(:open_response) }
      let(:meta_data)  { Portal::OfferingEmbeddableMetadata.find_by_offering_id_and_embeddable_id_and_embeddable_type(offering.id, embeddable.id, embeddable.class.name) }

      before(:each) do
        API::V1::Report.update_feedback_settings(offering, feedback_settings )
      end

      describe "setting enable_score, enable_feedback, and max_score of 10" do
        subject { meta_data }
        let(:enable_score)         { true }
        let(:enable_feedback)      { true }
        let(:max_score)            { 10   }

        describe '#max_score' do
          subject { super().max_score }
          it { is_expected.to be 10 }
        end

        describe '#enable_text_feedback' do
          subject { super().enable_text_feedback }
          it { is_expected.to be true }
        end

        describe '#enable_score' do
          subject { super().enable_score }
          it { is_expected.to be true }
        end

        describe "changing the max_score to 0" do
          let(:max_score)            { 0 }

          describe '#max_score' do
            subject { super().max_score }
            it { is_expected.to be 0 }
          end

          describe '#enable_text_feedback' do
            subject { super().enable_text_feedback }
            it { is_expected.to be true }
          end

          describe '#enable_score' do
            subject { super().enable_score }
            it { is_expected.to be true }
          end
        end

        describe "disabling text feedback" do
          let(:enable_feedback)      { false }

          describe '#max_score' do
            subject { super().max_score }
            it { is_expected.to be 10 }
          end

          describe '#enable_text_feedback' do
            subject { super().enable_text_feedback }
            it { is_expected.to be false }
          end

          describe '#enable_score' do
            subject { super().enable_score }
            it { is_expected.to be true  }
          end
        end
      end
    end

    describe "updating feedback on an answer" do
      let(:score)                { nil }
      let(:text_feedback)        { nil }
      let(:has_been_reviewed)    { nil }
      let(:open_response)        { FactoryBot.create(:open_response) }
      let(:learner)              { FactoryBot.create(:full_portal_learner) }
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
          expect(open_response_answer.needs_review?).to be_falsey
        end
      end

      describe "when an answer is given" do
        before(:each) do
          open_response_answer.answers.create(answer: "this is the answer")
          API::V1::Report.submit_feedback(feedback)
        end

        it "should indicate that it does need a review" do
          expect(open_response_answer.needs_review?).to be_truthy
        end

        describe 'giving feedback without marking complete' do
          let(:text_feedback)  { "good job" }
          let(:score)          {  10        }

          it "should indicate that it does need a review" do
            expect(open_response_answer.needs_review?).to be_truthy
          end

          it "should have the correct score" do
            expect(open_response_answer.current_score).to eq score
          end

          it "should have the correct feedback" do
            expect(open_response_answer.current_feedback).to eq text_feedback
          end
        end


        describe "marking the feedback complete" do
          let(:text_feedback)     { "good job!" }
          let(:score)             { 20          }
          let(:has_been_reviewed) { true        }

          it "should show that feedback is complete" do
            expect(open_response_answer.needs_review?).to be_falsey
          end

          it "should have the correct score" do
            expect(open_response_answer.answers.length.size).to be >= 1
            expect(open_response_answer.current_score).to eq score
          end

          it "should have the correct feedback" do
            expect(open_response_answer.current_feedback).to eq text_feedback
          end
        end
      end
    end

    describe "#page_json" do
      let(:url)    { "http//unlikely.com/foo/bar" }
      let(:page)   { FactoryBot.create(:page, url: url, name: "page 1") }
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
      let(:activity)         { FactoryBot.create(:activity) }
      let(:learner)          { FactoryBot.create(:full_portal_learner, {offering:offering}) }
      let(:student)          { learner.student }
      let(:learner_feedback) { Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner.id, activity_feedback.id) }
      let(:activity_feedback){ Portal::OfferingActivityFeedback.create_for_offering_and_activity(offering, activity) }
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
              learner.id,
              activity_feedback.id,
              { score: 4, text_feedback: text_feedback, has_been_reviewed: false  }
            )
            Portal::LearnerActivityFeedback.update_feedback(
              learner.id,
              activity_feedback.id,
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
              learner.id,
              activity_feedback.id,
              { score: 7, text_feedback: text_feedback, has_been_reviewed: true }
            )
          end

          it "should just one, most recent feedback record" do
            feedback = json[:activity_feedback].first
            expect(feedback[:feedbacks].length).to eql(1)
            expect(feedback[:feedbacks].first).to include({:score => 7})
          end
        end
      end

      describe "update activity feedback_settings using the API" do
        let(:enable_text_feedback)   { nil }
        let(:score_type)             { "none" }
        let(:max_score)              { nil }
        let(:use_rubric)             { nil }
        let(:rubric_url)             { nil }
        let(:rubric)                 { nil }
        let(:feedback_settings) do
          {
              'activity_feedback_id' => feedback_id,
              'learner_id' => learner_id,
              'max_score' => max_score,
              'score_type' => score_type,
              'enable_text_feedback' => enable_text_feedback,
              'use_rubric' => use_rubric,
              'rubric_url' => rubric_url,
              'rubric' => rubric
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

          describe '#max_score' do
            subject { super().max_score }
            it { is_expected.to eq 12 }
          end

          describe '#score_type' do
            subject { super().score_type }
            it { is_expected.to eq "manual" }
          end

          describe '#enable_text_feedback' do
            subject { super().enable_text_feedback }
            it { is_expected.to eq true }
          end

          describe "changing the max_score to 0" do
            let(:max_score)            { 0 }

            describe '#max_score' do
              subject { super().max_score }
              it { is_expected.to eq 0 }
            end

            describe '#enable_text_feedback' do
              subject { super().enable_text_feedback }
              it { is_expected.to eq true }
            end

            describe '#score_type' do
              subject { super().score_type }
              it { is_expected.to eq "manual"}
            end
          end

          describe "enabling auto scoring" do
            let(:score_type)           { "auto" }

            describe '#max_score' do
              subject { super().max_score }
              it { is_expected.to eq 12 }
            end

            describe '#enable_text_feedback' do
              subject { super().enable_text_feedback }
              it { is_expected.to be true }
            end

            describe '#score_type' do
              subject { super().score_type }
              it { is_expected.to eq "auto"  }
            end
          end

          describe "enabling rubric" do
            let(:use_rubric)   { true }

            describe '#use_rubric' do
              subject { super().use_rubric }
              it { is_expected.to be_truthy }
            end
          end

          describe "setting the rubric" do
            let(:rubric)   { {"version" => "1.0", "timestamp" => Time.now.to_i} }

            describe '#rubric' do
              subject { super().rubric }
              it { is_expected.to eql rubric }
            end
          end
        end
      end

      describe "updating activity feedback for a learner using the API" do
        let(:score)                { nil }
        let(:text_feedback)        { nil }
        let(:has_been_reviewed)    { nil }
        let(:rubric_feedback)      { nil }
        let(:feedback) do
          {
              'learner_id'           => learner_id,
              'activity_feedback_id' => feedback_id,
              'score'                => score,
              'text_feedback'        => text_feedback,
              'rubric_feedback'      => rubric_feedback,
              'has_been_reviewed'    => has_been_reviewed
          }
        end

        before(:each) do
          API::V1::Report.submit_activity_feedback(feedback)
        end

        describe "giving activity level feedback" do
          let(:learner_feedback) { Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner.id, activity_feedback.id)}
          describe 'giving feedback without marking complete' do
            let(:text_feedback)   { "good job" }
            let(:score)           {  10        }
            let(:rubric_feedback) { {"C1" => {"id"=>"R3"}} }
            subject             { learner_feedback.first }

            describe '#score' do
              subject { super().score }
              it { is_expected.to eql 10 }
            end

            describe '#text_feedback' do
              subject { super().text_feedback }
              it { is_expected.to eql "good job" }
            end

            describe '#rubric_feedback' do
              subject { super().rubric_feedback }
              it { is_expected.to eql rubric_feedback }
            end
          end

          describe "marking feedback complete" do
            subject                 { learner_feedback.first }
            let(:has_been_reviewed) { true }
            let(:score)             { 10   }

            describe '#has_been_reviewed' do
              subject { super().has_been_reviewed }
              it { is_expected.to be true }
            end

            it "Should update last feedback on next update." do
              expect(learner_feedback.size).to eq(1)
              API::V1::Report.submit_activity_feedback({
                "score"                => 11,
                "has_been_reviewed"    => true,
                "learner_id"           => learner_id,
                "activity_feedback_id" => feedback_id
              })
              new_feedback = Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner.id, activity_feedback.id)
              expect(new_feedback.size).to eq(1)
              expect(new_feedback.first.score).to eq(11)
            end
          end
        end
      end
    end

  end



  # TODO: auto-generated
  describe '#is_teacher?' do
    xit 'is_teacher?' do
      options = {}
      report = described_class.new(options)
      user = FactoryBot.create(:user)
      result = report.is_teacher?(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_student?' do
    xit 'is_student?' do
      options = {}
      report = described_class.new(options)
      user = FactoryBot.create(:user)
      result = report.is_student?(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_report_for_student?' do
    xit 'is_report_for_student?' do
      options = {}
      report = described_class.new(options)
      user = FactoryBot.create(:user)
      result = report.is_report_for_student?(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#to_json' do
    xit 'to_json' do
      options = {}
      report = described_class.new(options)
      result = report.to_json

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#class_json' do
    xit 'class_json' do
      options = {}
      report = described_class.new(options)
      result = report.class_json

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_json' do
    xit 'student_json' do
      options = {}
      report = described_class.new(options)
      student = double('student')
      result = report.student_json(student)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_student_answers' do
    xit 'get_student_answers' do
      options = {}
      report = described_class.new(options)
      result = report.get_student_answers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#no_answer_for_student_id' do
    xit 'no_answer_for_student_id' do
      options = {}
      report = described_class.new(options)
      student_id = double('student_id')
      embeddable_key = double('embeddable_key')
      result = report.no_answer_for_student_id(student_id, embeddable_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#provide_no_answer_entries' do
    xit 'provide_no_answer_entries' do
      options = {}
      report = described_class.new(options)
      answers = {}
      students_json = double('students_json')
      result = report.provide_no_answer_entries(answers, students_json)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_multiple_choice_answer' do
    xit 'process_multiple_choice_answer' do
      options = {}
      report = described_class.new(options)
      hash = double('hash')
      result = report.process_multiple_choice_answer(hash)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_image_question_answer' do
    xit 'process_image_question_answer' do
      options = {}
      report = described_class.new(options)
      hash = double('hash')
      result = report.process_image_question_answer(hash)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#report_json' do
    xit 'report_json' do
      options = {}
      report = described_class.new(options)
      answers = {}
      result = report.report_json(answers)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#investigation_json' do
    xit 'investigation_json' do
      options = {}
      report = described_class.new(options)
      investigation = FactoryBot.create(:investigation)
      answers = {}
      associations_to_load = double('associations_to_load')
      result = report.investigation_json(investigation, answers, associations_to_load)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#activity_json' do
    xit 'activity_json' do
      options = {}
      report = described_class.new(options)
      activity = Activity.new
      answers = {}
      associations_to_load = double('associations_to_load')
      result = report.activity_json(activity, answers, associations_to_load)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#learner_activity_feedback_json' do
    xit 'learner_activity_feedback_json' do
      options = {}
      report = described_class.new(options)
      learner = double('learner')
      activity_feedback = double('activity_feedback')
      result = report.learner_activity_feedback_json(learner, activity_feedback)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#section_json' do
    xit 'section_json' do
      options = {}
      report = described_class.new(options)
      section = double('section')
      answers = {}
      result = report.section_json(section, answers)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#page_json' do
    xit 'page_json' do
      options = {}
      report = described_class.new(options)
      page = double('page')
      answers = {}
      result = report.page_json(page, answers)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#embeddable_json' do
    xit 'embeddable_json' do
      options = {}
      report = described_class.new(options)
      question_number = double('question_number')
      embeddable = FactoryBot.create(:open_response)
      answers = {}
      result = report.embeddable_json(question_number, embeddable, answers)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_multiple_choice' do
    xit 'process_multiple_choice' do
      options = {}
      report = described_class.new(options)
      hash = double('hash')
      embeddable = FactoryBot.create(:open_response)
      result = report.process_multiple_choice(hash, embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_iframe' do
    xit 'process_iframe' do
      options = {}
      report = described_class.new(options)
      hash = double('hash')
      embeddable = FactoryBot.create(:open_response)
      result = report.process_iframe(hash, embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#no_answers' do
    xit 'no_answers' do
      options = {}
      report = described_class.new(options)
      embeddable_key = double('embeddable_key')
      result = report.no_answers(embeddable_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#visibility_filter_json' do
    xit 'visibility_filter_json' do
      options = {}
      report = described_class.new(options)
      filter = double('filter')
      result = report.visibility_filter_json(filter)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.decode_embeddable' do
    xit 'decode_embeddable' do
      embeddable_key = double('embeddable_key')
      result = described_class.decode_embeddable(embeddable_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.embeddable_type' do
    xit 'embeddable_type' do
      embeddable_key = double('embeddable_key')
      result = described_class.embeddable_type(embeddable_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.embeddable_key' do
    xit 'embeddable_key' do
      embeddable = FactoryBot.create(:open_response)
      result = described_class.embeddable_key(embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.decode_answer_key' do
    xit 'decode_answer_key' do
      answer_key = double('answer_key')
      result = described_class.decode_answer_key(answer_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.encode_answer_key' do
    xit 'encode_answer_key' do
      saveable = double('saveable')
      result = described_class.encode_answer_key(saveable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.update_feedback_settings' do
    xit 'update_feedback_settings' do
      offering = FactoryBot.create(:portal_offering)
      feedback_settings = double('feedback_settings')
      result = described_class.update_feedback_settings(offering, feedback_settings)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.submit_feedback' do
    xit 'submit_feedback' do
      answer_feedback_hash = double('answer_feedback_hash')
      result = described_class.submit_feedback(answer_feedback_hash)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.update_activity_feedback_settings' do
    it 'update_activity_feedback_settings' do
      activity_feedback_hash = {}
      result = described_class.update_activity_feedback_settings(activity_feedback_hash)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.submit_activity_feedback' do
    it 'submit_activity_feedback' do
      activity_feedback_hash = {}
      result = described_class.submit_activity_feedback(activity_feedback_hash)

      expect(result).to be_nil
    end
  end


end
