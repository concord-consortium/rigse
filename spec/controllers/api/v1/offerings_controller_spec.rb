require 'spec_helper'
include ReportLearnerSpecHelper

describe API::V1::OfferingsController do
  let(:admin_user)        { Factory.next(:admin_user)     }
  let(:simple_user)       { Factory.next(:confirmed_user) }
  let(:manager_user)      { Factory.next(:manager_user)   }
  let(:teacher)           { Factory.create(:portal_teacher)}

  describe "#show" do
    let(:fake_json)         { {fake:true}.to_json  }
    let(:mock_offering)     { mock_model Portal::Offering }
    let(:mock_api_offering) { mock(to_json: fake_json) }
    let(:mock_offering_id)  { 32 }
    let(:offering_teachers) { [] }

    before(:each) do
      Portal::Offering.stub!(:find).and_return(mock_offering)
      mock_offering.stub_chain(:clazz, :is_teacher?).and_return { |t| offering_teachers.include?(t) }
    end

    describe "anonymous' access" do
      before (:each) do
        logout_user
      end

      describe "GET show" do
        it "wont allow show, returns error 403" do
          get :show, :id => mock_offering_id
          response.status.should eql(403)
        end
      end
    end

    describe "manager access" do
      before (:each) do
        sign_in manager_user
      end
      describe "GET show" do
        it "wont allow show, returns error 403" do
          get :show, :id => mock_offering_id
          response.status.should eql(403)
        end
      end
    end

    describe "admin access" do
      before (:each) do
        sign_in admin_user
        API::V1::Offering.should_receive(:new).and_return(mock_api_offering)
      end
      describe "GET show" do
        it "renders the show template" do
          get :show, :id => mock_offering_id
          assigns[:offering_api].should eq mock_api_offering
          response.status.should eq 200
          response.body.should eq fake_json
        end
      end
    end

    describe "teacher access" do
      let(:offering_teachers) { [] }
      before(:each) do
        sign_in teacher.user
      end
      describe "when the offering doesn't belong to the teachers class" do
        let(:offering_teachers) { [] }
        it "wont allow show, returns error 403" do
          get :show, :id => mock_offering_id
          response.status.should eql(403)
        end
      end

      describe "when the offering belongs to the teachers class" do
        let(:offering_teachers) { [teacher.user] }
        describe "GET show" do
          it "renders the show template" do
            API::V1::Offering.should_receive(:new).and_return(mock_api_offering)
            get :show, :id => mock_offering_id
            assigns[:offering_api].should eq mock_api_offering
            response.status.should eq 200
            response.body.should eq fake_json
          end
        end
      end
    end
  end

  describe "for_current_user" do
    let(:open_response_1)   { Factory.create(:open_response) }
    let(:open_response_2)   { Factory.create(:open_response) }
    let(:open_response_3)   { Factory.create(:open_response) }
    let(:open_response_4)   { Factory.create(:open_response) }
    let(:activity_1)        { Factory.create(:activity, name: 'Activity 1') }
    let(:activity_2)        { Factory.create(:activity, name: 'Activity 2') }
    let(:runnable)          { Factory.create(:external_activity, name: 'Test Sequence') }
    let(:clazz)             { Factory(:portal_clazz, name: 'test class', teachers: [teacher], students:[student_a, student_b]) }
    let(:offering_opts)     { {clazz: clazz, runnable: runnable}  }
    let(:student_a)         { FactoryGirl.create(:full_portal_student) }
    let(:student_b)         { FactoryGirl.create(:full_portal_student) }

    def setup_activity(activity, embeddables)
      section = Factory.create(:section)
      page = Factory.create(:page)
      embeddables.each { |e| page.add_embeddable(e) }
      section.pages << page
      activity.sections << section
      activity.save
    end

    def setup_runnable(runnable, activities)
      investigation = Factory.create(:investigation)
      activities.each { |a| investigation.activities << a }
      investigation.save
      runnable.template = investigation
      runnable.save
    end

    def add_answer(offering, student, question)
      learner = Portal::Learner.find_or_create_by_offering_id_and_student_id(offering.id, student.id)
      add_answer_for_learner(learner, question, {answer: "Some answer"})
      learner.report_learner.update_answers()
      learner.report_learner.save
    end

    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        logout_user
        get :for_current_user
        response.status.should eql(403)
      end
    end

    describe "when user does not have any offerings" do
      before (:each) do
        # Create a new teacher without any offerings.
        sign_in Factory.create(:portal_teacher).user
      end
      it "returns an empty array" do
        get :for_current_user
        response.status.should eq 200
        response.body.should eq [].to_json
      end
    end

    describe "when user have an offering but no students have run it" do
      before (:each) do
        # Create a new teacher without any offerings.
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3])
        setup_runnable(runnable, [activity_1, activity_2])
        @offering = Factory(:portal_offering, offering_opts)
      end
      it "returns an description of the activity and students list with 0 progress" do
        get :for_current_user
        response.status.should eq 200
        json = JSON.parse(response.body)
        offering = json[0]
        offering["id"] = @offering.id
        offering["clazz"].should eq clazz.name
        offering["activity"].should eq runnable.name
        offering["students"].length.should eq 2

        student1 = offering["students"][0]
        student1["first_name"].should eq student_a.user.first_name
        student1["last_name"].should eq student_a.user.last_name
        student1["started_activity"].should eq false
        student1["last_run"].should eq nil
        student1["total_progress"].should eq 0
        student1["detailed_progress"].should eq nil

        student2 = offering["students"][1]
        student2["first_name"].should eq student_b.user.first_name
        student2["last_name"].should eq student_b.user.last_name
        student2["started_activity"].should eq false
        student2["last_run"].should eq nil
        student2["total_progress"].should eq 0
        student2["detailed_progress"].should eq nil
      end
    end

    describe "when user have an offering and some students have run it - case 1" do
      before (:each) do
        # Create a new teacher without any offerings.
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3, open_response_4])
        setup_runnable(runnable, [activity_1, activity_2])
        offering = Factory(:portal_offering, offering_opts)
        # Just one answer to the first question (out of 4). It means that the student made 25% progress.
        add_answer_for_student(student_a, offering, open_response_1, {answer: "Some answer"})
      end
      it "returns an description of the activity and students list with appropriate progress" do
        get :for_current_user
        response.status.should eq 200
        json = JSON.parse(response.body)
        offering = json[0]
        student1 = offering["students"][0]
        student1["started_activity"].should eq true
        student1["last_run"].should_not eq nil
        student1["total_progress"].should eq 25
        student1["detailed_progress"].should eq [
                                                  { "activity" => activity_1.name, "progress" => 50 },
                                                  { "activity" => activity_2.name, "progress" => 0 }
                                                ]

        student2 = offering["students"][1]
        student2["started_activity"].should eq false
        student2["last_run"].should eq nil
        student2["total_progress"].should eq 0
        student2["detailed_progress"].should eq nil
      end
    end

    describe "when user have an offering and some students have run it - case 2" do
      before (:each) do
        # Create a new teacher without any offerings.
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3, open_response_4])
        setup_runnable(runnable, [activity_1, activity_2])
        offering = Factory(:portal_offering, offering_opts)

        add_answer_for_student(student_a, offering, open_response_1, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_3, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_4, {answer: "Some answer"})
      end
      it "returns an description of the activity and students list with appropriate progress" do
        get :for_current_user
        response.status.should eq 200
        json = JSON.parse(response.body)
        offering = json[0]
        student1 = offering["students"][0]
        student1["started_activity"].should eq true
        student1["last_run"].should_not eq nil
        student1["total_progress"].should eq 25
        student1["detailed_progress"].should eq [
                                                    { "activity" => activity_1.name, "progress" => 50 },
                                                    { "activity" => activity_2.name, "progress" => 0 }
                                                ]

        student2 = offering["students"][1]
        student2["started_activity"].should eq true
        student2["last_run"].should_not eq nil
        student2["total_progress"].should eq 50
        student2["detailed_progress"].should eq [
                                                    { "activity" => activity_1.name, "progress" => 0 },
                                                    { "activity" => activity_2.name, "progress" => 100 }
                                                ]
      end
    end

    describe "when user have an offering and all students completed it" do
      before (:each) do
        # Create a new teacher without any offerings.
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3, open_response_4])
        setup_runnable(runnable, [activity_1, activity_2])
        offering = Factory(:portal_offering, offering_opts)

        add_answer_for_student(student_a, offering, open_response_1, {answer: "Some answer"})
        add_answer_for_student(student_a, offering, open_response_2, {answer: "Some answer"})
        add_answer_for_student(student_a, offering, open_response_3, {answer: "Some answer"})
        add_answer_for_student(student_a, offering, open_response_4, {answer: "Some answer"})

        add_answer_for_student(student_b, offering, open_response_1, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_2, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_3, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_4, {answer: "Some answer"})
      end
      it "returns an description of the activity and students list with appropriate progress" do
        get :for_current_user
        response.status.should eq 200
        json = JSON.parse(response.body)
        offering = json[0]
        student1 = offering["students"][0]
        student1["started_activity"].should eq true
        student1["last_run"].should_not eq nil
        student1["total_progress"].should eq 100
        student1["detailed_progress"].should eq [
                                                    { "activity" => activity_1.name, "progress" => 100 },
                                                    { "activity" => activity_2.name, "progress" => 100 }
                                                ]

        student2 = offering["students"][1]
        student2["started_activity"].should eq true
        student2["last_run"].should_not eq nil
        student2["total_progress"].should eq 100
        student2["detailed_progress"].should eq [
                                                    { "activity" => activity_1.name, "progress" => 100 },
                                                    { "activity" => activity_2.name, "progress" => 100 }
                                                ]
      end
    end
  end
end
