require 'spec_helper'

include ReportLearnerSpecHelper # defines : saveable_for : answers_for : add_answer : stub_all_reportables

RSpec::Matchers.define :include_hash do |comp_hash|
  match do |actual|
    found = false
    actual.each do |test|
      hash_matched = true
      comp_hash.each_pair do |key,value|
        hash_matched = hash_matched && test.has_key?(key) && test[key] == value
      end
      found = hash_matched
      break if found
    end
    found
  end
end

describe API::V1::ReportsController do
  let(:open_response)     { FactoryBot.create(:open_response, show_in_featured_question_report: true, is_required: true)}
  let(:section)           { FactoryBot.create(:section) }
  let(:page)              { FactoryBot.create(:page) }
  let(:activity)          { FactoryBot.create(:activity, runnable_opts)          }
  let(:runnable)          { FactoryBot.create(:external_activity, runnable_opts) }
  let(:offering)          { FactoryBot.create(:portal_offering, offering_opts)    }
  let(:clazz)             { FactoryBot.create(:portal_clazz, teachers: [class_teacher], students:[student_a,student_b]) }
  let(:offering_opts)     { {clazz: clazz, runnable: runnable}  }
  let(:runnable_opts)     { {name: 'the activity'}              }
  let(:class_teacher)     { FactoryBot.create(:portal_teacher)     }
  let(:learner_a)         { Portal::Learner.where(offering_id: offering.id, student_id: student_a.id).first_or_create}
  let(:learner_b)         { Portal::Learner.where(offering_id: offering.id, student_id: student_b.id).first_or_create}
  let(:student_a)         { FactoryBot.create(:full_portal_student) }
  let(:student_b)         { FactoryBot.create(:full_portal_student) }
  let(:report_learner_a)  { learner_a.report_learner }
  let(:report_learner_b)  { learner_b.report_learner }
  let(:user)              { class_teacher.user       }
  let(:learner)           { learner_a }

  def json_path(path_string)
    json =  JSON.parse(response.body)

    path_string.split(".").each do |segment|
      json = json[segment]
    end
    json
  end

  def update(opts)
    put :update, params: opts
  end

  def show
    get :show, params: { :id => offering.id }
  end

  def question
    json_path("report.children")[0]['children'][0]['children'][0]
  end

  def answers
    question['answers']
  end

  def feedback_should_be_enabled
    expect(question).to include({"feedback_enabled" => true})
  end

  def feedback_should_be_disabled
    expect(question).to include({"feedback_enabled" => false})
  end

  def score_should_be_enabled
    expect(question).to include({"score_enabled" => true})
  end

  def score_should_be_disabled
    expect(question).to include({"score_enabled" => false})
  end

  def max_score_should_be(value)
    expect(question).to include({"max_score" => value})
  end

  before(:each) do
    page.add_embeddable(open_response)
    section.pages << page
    activity.sections << section
    activity.save
    runnable.template = activity
    runnable.save
    allow(Portal::Offering).to receive(:find).and_return(offering)
    sign_in user
    add_answer_for_learner(learner_a, open_response, {"answer" => "testing from #{learner_a.student.user.id}"} )
    add_answer_for_learner(learner_b, open_response, {"answer" => "testing from #{learner_b.student.user.id}"} )
    report_learner_a.update_answers()
    report_learner_b.update_answers()
    report_learner_a.save
    report_learner_b.save
  end


  describe "GET show" do
    describe "For the offering's teacher" do
      it 'should render the report json' do
        show
        expect(response.status).to eql(200)
        expect(json_path("report_version")).to eql "1.1.0"
        expect(json_path("report.name")).to eql "the activity"
        expect(json_path("class.students")).to include_hash({"started_offering"=>true, "name"=>"joe user"})
        max_score_should_be 0
        feedback_should_be_disabled
        score_should_be_disabled
        expect(question).to include({"show_in_featured_question_report" => true})
        expect(question).to include({"is_required" => true})
        expect(answers).to include_hash({"answer" => "testing from #{learner_a.student.user.id}"})
      end
    end
    describe "For an anonymous user" do
      it "should return 403" do
        logout_user
        show
        expect(response.status).to eql(403)
      end
    end
  end

  describe "changing the view filter" do
    let(:active)             { false }
    let(:questions)          { [] }
    let(:visibility_filter)  { { questions: questions, active: active} }
    let(:opts) { {id: offering.id, visibility_filter: visibility_filter } }

    describe "to off" do
      let(:active)             { false }
      it "should save the filter settings" do
        update opts
        show
        expect(response.status).to eql 200
        expect(json_path("visibility_filter.active")).to be_falsey
      end
    end

    describe "to on" do
      let(:active)             { true }
      it "should save the filter settings" do
        update(opts)
        show
        expect(response.status).to eql(200)
        expect(json_path("visibility_filter.active")).to be_truthy
      end
    end
  end

  describe "enabling feedback options for a question in the report" do
    let(:enable_feedback)     { false }
    let(:enable_score)        { false }
    let(:max_score)            { 0 }
    let(:embeddable_key)       { API::V1::Report.embeddable_key(open_response) }
    let(:feedback_opts)        do
      {
          'embeddable_key'       => embeddable_key ,
          'enable_text_feedback' => enable_feedback,
          'enable_score'         => enable_score,
          'max_score'            => max_score
      }
    end
    let(:opts) { {id: offering.id, feedback_opts: feedback_opts} }
    # enable_feedback(offering, question, feedback_enabled, score_enabled, max_score)
    describe "when disabling feedback for our question" do
      it "should disable feedback for our question" do
        update(opts)
        show
        expect(response.status).to eql(200)
        md = Portal::OfferingEmbeddableMetadata.find_by_offering_id_and_embeddable_id_and_embeddable_type(offering.id, open_response.id, open_response.class.name)
        expect(md.enable_text_feedback).to be_falsey
        expect(md.enable_score).to be_falsey
        expect(md.max_score).to eq 0
      end
    end

    describe "when enabling score only for our question" do
      let(:enable_score)  { true }
      it "should disable feedback for our question" do
        update(opts)
        show
        expect(response.status).to eql(200)
        md = Portal::OfferingEmbeddableMetadata.find_by_offering_id_and_embeddable_id_and_embeddable_type(offering.id, open_response.id, open_response.class.name)
        expect(md.enable_text_feedback).to be_falsey
        expect(md.enable_score).to be_truthy
        expect(md.max_score).to eq 0
      end
    end

    describe "when chaging the max score to 20" do
      let(:max_score)   { 20 }
      it "should disable feedback for our question" do
        update(opts)
        show
        expect(response.status).to eql(200)
        md = Portal::OfferingEmbeddableMetadata.find_by_offering_id_and_embeddable_id_and_embeddable_type(offering.id, open_response.id, open_response.class.name)
        expect(md.enable_text_feedback).to be_falsey
        expect(md.enable_score).to be_falsey
        expect(md.max_score).to eq 20
      end
    end
  end

  describe "enabling feedback options for an activity" do
    let(:activity_feedback)    { Portal::OfferingActivityFeedback.create_for_offering_and_activity(offering, activity) }
    let(:activity_feedback_id) { activity_feedback.id }
    let(:found_feedback)       { Portal::OfferingActivityFeedback.find(activity_feedback_id)}
    let(:enable_text_feedback) { false }
    let(:score_type)           { Portal::OfferingActivityFeedback::SCORE_NONE }
    let(:max_score)            { 10 }
    let(:use_rubric)           { false }
    let(:opts)                 do
      {
        actvity_feedback_opts: {
          activity_feedback_id: activity_feedback_id,
          enable_text_feedback: enable_text_feedback,
          score_type: score_type,
          max_score: max_score,
          use_rubric: use_rubric
        }
      }
    end
    let(:opts_v2)               do
      {
        activity_feedback_opts_v2: {
          enable_text_feedback: enable_text_feedback,
          score_type: score_type,
          max_score: max_score,
          use_rubric: use_rubric,
          activity_index: 0
        }
      }
    end

    describe "switching to automatic scoring from the API" do
      let(:score_type)  { Portal::OfferingActivityFeedback::SCORE_AUTO  }
      it "should make the scoring automatic" do
        update(opts)
        show
        expect(response.status).to eql(200)
        expect(found_feedback.score_type).to eql Portal::OfferingActivityFeedback::SCORE_AUTO
        expect(found_feedback.enable_text_feedback).to be_falsey
        expect(found_feedback.max_score).to eq 10
      end
      it "should make the scoring automatic (v2)" do
        activity_feedback # ensure that activity_feedback object gets created before we start updating feedback
        update(opts_v2)
        show
        expect(response.status).to eql(200)
        expect(found_feedback.score_type).to eql Portal::OfferingActivityFeedback::SCORE_AUTO
        expect(found_feedback.enable_text_feedback).to be_falsey
        expect(found_feedback.max_score).to eq 10
      end
    end

    describe "when chaging the max score to 20" do
      let(:max_score)   { 20 }
      it "should make max score be 20" do
        update(opts)
        show
        expect(response.status).to eql(200)
        expect(found_feedback.max_score).to eq 20
      end
      it "should make max score be 20 (v2)" do
        activity_feedback # ensure that activity_feedback object gets created before we start updating feedback
        update(opts_v2)
        show
        expect(response.status).to eql(200)
        expect(found_feedback.max_score).to eq 20
      end
    end

    describe "when enabling a rubric" do
      let(:use_rubric)    { true }
      it "should specify to use a rubric" do
        update(opts)
        show
        expect(response.status).to eql(200)
        expect(found_feedback.use_rubric).to be_truthy
      end
      it "should specify to use a rubric (v2)" do
        activity_feedback # ensure that activity_feedback object gets created before we start updating feedback
        update(opts_v2)
        show
        expect(response.status).to eql(200)
        expect(found_feedback.use_rubric).to be_truthy
      end
    end
  end

  describe "posting learner activity feedback" do
    let(:learner_id)          { learner_a.id }
    let(:activity_feedback)   { Portal::OfferingActivityFeedback.create_for_offering_and_activity(offering, activity) }
    let(:activity_feedback_id){ activity_feedback.id }
    let(:score) { 10 }
    let(:text_feedback) { "good work" }
    let(:rubric_feedback) do
      {
        C1: {
          id: "R1",
          score: 1,
          label: "Beginning",
          description: "Not meeting expected goals."
        },
        C2: {
          id: "R2",
          score: 2,
          label: "Developing",
          description: "Approaching proficiency."
        }
      }
    end
    let(:opts) do
      {
        activity_feedback: {
          learner_id: learner_id,
          activity_feedback_id: activity_feedback_id,
          score: score,
          rubric_feedback: rubric_feedback,
          text_feedback: text_feedback
        }
      }
    end
    let(:opts_v2) do
      {
        activity_feedback_v2: {
          score: score,
          rubric_feedback: rubric_feedback,
          text_feedback: text_feedback,
          student_user_id: learner_a.user.id,
          activity_index: 0
        }
      }
    end

    it "should update the learners feedback" do
      update(opts)
      show
      expect(response.status).to eql(200)
      feedback = Portal::LearnerActivityFeedback.open_feedback_for(learner, activity_feedback)
      expect(feedback.rubric_feedback["C1"]["id"]).to eql "R1"
    end

    it "should update the learners feedback (v2)" do
      activity_feedback # ensure that activity_feedback object gets created before we start updating feedback
      update(opts_v2)
      show
      expect(response.status).to eql(200)
      feedback = Portal::LearnerActivityFeedback.open_feedback_for(learner, activity_feedback)
      expect(feedback.rubric_feedback["C1"]["id"]).to eql "R1"
    end
  end

  describe "posting a rubric JSON" do
    let(:rubric_content) { { "test_rubric" => "content" } }
    let(:opts_v2) do
      {
        rubric_v2: {
          rubric: rubric_content
        }
      }
    end

    describe "when runnable is an activity" do
      let(:activity_feedback) { Portal::OfferingActivityFeedback.create_for_offering_and_activity(offering, activity) }

      it "should update activity feedback model" do
        activity_feedback # ensure that activity_feedback object gets created before we start updating feedback
        update(opts_v2)
        show
        expect(response.status).to eql(200)
        expect(Portal::OfferingActivityFeedback.find(activity_feedback.id).rubric).to eql rubric_content
      end
    end

    describe "when runnable is a sequence" do
      let(:activity_1) { FactoryBot.create(:activity) }
      let(:activity_2) { FactoryBot.create(:activity) }
      let(:investigation) { FactoryBot.create(:investigation) }
      let(:activity_feedback_1) { Portal::OfferingActivityFeedback.create_for_offering_and_activity(offering, activity_1) }
      let(:activity_feedback_2) { Portal::OfferingActivityFeedback.create_for_offering_and_activity(offering, activity_2) }

      before(:each) do
        investigation.activities << activity_1
        investigation.activities << activity_2
        investigation.save
        runnable.template = investigation
        runnable.save
      end

      it "should update all the activity feedback models" do
        activity_feedback_1 # ensure that activity_feedback_1 object gets created before we start updating feedback
        activity_feedback_2 # ensure that activity_feedback_2 object gets created before we start updating feedback
        update(opts_v2)
        show
        expect(response.status).to eql(200)
        expect(Portal::OfferingActivityFeedback.find(activity_feedback_1.id).rubric).to eql rubric_content
        expect(Portal::OfferingActivityFeedback.find(activity_feedback_2.id).rubric).to eql rubric_content
      end
    end
  end
end
