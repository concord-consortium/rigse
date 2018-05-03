require 'spec_helper'
include ReportLearnerSpecHelper

describe API::V1::OfferingsController do
  let(:admin_user)        { Factory.next(:admin_user) }
  let(:manager_user)      { Factory.next(:manager_user) }
  let(:teacher)           { Factory.create(:portal_teacher) }
  let(:open_response_1)   { Factory.create(:open_response) }
  let(:open_response_2)   { Factory.create(:open_response) }
  let(:open_response_3)   { Factory.create(:open_response) }
  let(:open_response_4)   { Factory.create(:open_response) }
  let(:activity_1)        { Factory.create(:activity, name: 'Activity 1') }
  let(:activity_2)        { Factory.create(:activity, name: 'Activity 2') }
  let(:runnable)          { Factory.create(:external_activity, name: 'Test Sequence') }
  let(:clazz)             { Factory.create(:portal_clazz, name: 'test class', teachers: [teacher], students:[student_a, student_b]) }
  let(:student_a)         { Factory.create(:full_portal_student) }
  let(:student_b)         { Factory.create(:full_portal_student) }
  let(:offering)          { Factory.create(:portal_offering, {clazz: clazz, runnable: runnable}) }

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

  describe "GET #show (+ basic response structure tests)" do

    describe "when there is no offering with given ID" do
      it "returns 404" do
        get :show, id: 123
        response.status.should eq 404
      end
    end

    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        get :show, id: offering.id
        response.status.should eql(403)
      end
    end

    describe "when user is manager" do
      before (:each) do
        sign_in manager_user
      end
      it "returns error 403" do
        get :show, :id => offering.id
        response.status.should eql(403)
      end
    end

    describe "when user is an admin" do
      before (:each) do
        sign_in admin_user
      end
      it "returns 200 and valid JSON response" do
        get :show, :id => offering.id
        response.status.should eq 200
        json = JSON.parse(response.body)
        json.should_not eq nil
      end
    end

    describe "when user is a teacher" do
      describe "when the offering doesn't belong to the teachers class" do
        before(:each) do
          other_teacher = Factory.create(:portal_teacher)
          sign_in other_teacher.user
        end
        it "returns error 403" do
          get :show, :id => offering.id
          response.status.should eq 403
        end
      end

      describe "when the offering belongs to the teachers class" do
        before(:each) do
          sign_in teacher.user
        end
        it "returns 200 and valid JSON response" do
          get :show, :id => offering.id
          response.status.should eq 200
          json = JSON.parse(response.body)
          json.should_not eq nil
        end
      end
    end

    describe "when no students have run an offering" do
      before (:each) do
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3])
        setup_runnable(runnable, [activity_1, activity_2])
      end
      it "returns an description of the activity and students list with 0 progress" do
        get :show, id: offering.id
        response.status.should eq 200
        json = JSON.parse(response.body)
        json["id"] = offering.id
        json["clazz"].should eq clazz.name
        json["activity"].should eq runnable.name
        json["report_url"].should eql report_portal_offering_url(id: offering.id, host: 'test.host')
        json["students"].length.should eq 2

        student1 = json["students"][0]
        student1["first_name"].should eq student_a.user.first_name
        student1["last_name"].should eq student_a.user.last_name
        student1["started_activity"].should eq false
        student1["last_run"].should eq nil
        student1["total_progress"].should eq 0
        student1["detailed_progress"].should eq nil

        student2 = json["students"][1]
        student2["first_name"].should eq student_b.user.first_name
        student2["last_name"].should eq student_b.user.last_name
        student2["started_activity"].should eq false
        student2["last_run"].should eq nil
        student2["total_progress"].should eq 0
        student2["detailed_progress"].should eq nil
      end
    end

    describe "when some students have run an offering - case 1" do
      before (:each) do
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3, open_response_4])
        setup_runnable(runnable, [activity_1, activity_2])
        # Just one answer to the first question (out of 4). It means that the student made 25% progress.
        add_answer_for_student(student_a, offering, open_response_1, {answer: "Some answer"})
      end
      it "returns an description of the activity and students list with appropriate progress" do
        get :show, id: offering.id
        response.status.should eq 200
        json = JSON.parse(response.body)
        student1 = json["students"][0]
        student1["started_activity"].should eq true
        student1["last_run"].should_not eq nil
        student1["total_progress"].should eq 25
        student1["detailed_progress"][0]["activity_name"].should eq activity_1.name
        student1["detailed_progress"][0]["progress"].should eq 50
        student1["detailed_progress"][1]["activity_name"].should eq activity_2.name
        student1["detailed_progress"][1]["progress"].should eq 0

        student2 = json["students"][1]
        student2["started_activity"].should eq false
        student2["last_run"].should eq nil
        student2["total_progress"].should eq 0
        student2["detailed_progress"].should eq nil
      end
    end

    describe "when some students have run an offering - case 2" do
      before (:each) do
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3, open_response_4])
        setup_runnable(runnable, [activity_1, activity_2])

        add_answer_for_student(student_a, offering, open_response_1, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_3, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_4, {answer: "Some answer"})
      end
      it "returns an description of the activity and students list with appropriate progress" do
        get :show, id: offering.id
        response.status.should eq 200
        json = JSON.parse(response.body)
        student1 = json["students"][0]
        student1["started_activity"].should eq true
        student1["last_run"].should_not eq nil
        student1["total_progress"].should eq 25
        student1["detailed_progress"][0]["activity_name"].should eq activity_1.name
        student1["detailed_progress"][0]["progress"].should eq 50
        student1["detailed_progress"][1]["activity_name"].should eq activity_2.name
        student1["detailed_progress"][1]["progress"].should eq 0

        student2 = json["students"][1]
        student2["started_activity"].should eq true
        student2["last_run"].should_not eq nil
        student2["total_progress"].should eq 50
        student2["detailed_progress"][0]["activity_name"].should eq activity_1.name
        student2["detailed_progress"][0]["progress"].should eq 0
        student2["detailed_progress"][1]["activity_name"].should eq activity_2.name
        student2["detailed_progress"][1]["progress"].should eq 100
      end
    end

    describe "when all students completed an offering" do
      before (:each) do
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3, open_response_4])
        setup_runnable(runnable, [activity_1, activity_2])

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
        get :show, id: offering.id
        response.status.should eq 200
        json = JSON.parse(response.body)
        student1 = json["students"][0]
        student1["started_activity"].should eq true
        student1["last_run"].should_not eq nil
        student1["total_progress"].should eq 100
        student1["detailed_progress"][0]["activity_name"].should eq activity_1.name
        student1["detailed_progress"][0]["progress"].should eq 100
        student1["detailed_progress"][1]["activity_name"].should eq activity_2.name
        student1["detailed_progress"][1]["progress"].should eq 100


        student2 = json["students"][1]
        student2["started_activity"].should eq true
        student2["last_run"].should_not eq nil
        student2["total_progress"].should eq 100
        student2["detailed_progress"][0]["activity_name"].should eq activity_1.name
        student2["detailed_progress"][0]["progress"].should eq 100
        student2["detailed_progress"][1]["activity_name"].should eq activity_2.name
        student2["detailed_progress"][1]["progress"].should eq 100
      end
    end

    describe "when offering has an external report" do
      let (:external_report) { FactoryGirl.create(:external_report) }

      before (:each) do
        sign_in teacher.user
        runnable.external_report = external_report
        runnable.save
      end
      it "returns information about external report" do
        get :show, id: offering.id
        response.status.should eq 200
        json = JSON.parse(response.body)
        json["external_report"].should_not eq nil
        json["external_report"]["url"].should eq portal_external_report_url(id: offering.id, report_id: external_report.id, host: 'test.host')
        json["external_report"]["launch_text"].should eq external_report.launch_text
      end
    end
  end

  describe "GET #index" do
    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        get :index
        response.status.should eql(403)
      end
    end

    describe "when user is a student" do
      before (:each) do
        sign_in student_a.user
      end
      it "returns 403 error" do
        get :index
        response.status.should eql(403)
      end
    end

    describe "when user is a teacher, but have no offerings" do
      before (:each) do
        sign_in teacher.user
      end
      it "returns an empty array" do
        get :index
        response.status.should eql(200)
        json = JSON.parse(response.body)
        json.should eq []
      end
    end

    describe "when user is a teacher and have some offerings" do
      before (:each) do
        sign_in teacher.user
        # Make sure that the offering is created.
        @offering = offering
      end
      it "returns 200 and valid json response" do
        get :index
        response.status.should eql(200)
        json = JSON.parse(response.body)
        json.length.should eq 1
      end
    end

    describe "when there are multiple teachers, classes and offerings" do
      let(:teacher_b)  { Factory.create(:portal_teacher) }
      let(:clazz_b)    { Factory.create(:portal_clazz, teachers: [teacher_b]) }
      let(:offering_b) { Factory.create(:portal_offering, {clazz: clazz_b, runnable: runnable}) }

      let(:clazz_2)    { Factory.create(:portal_clazz, teachers: [teacher]) }
      let(:offering_2) { Factory.create(:portal_offering, {clazz: clazz_2, runnable: runnable}) }

      describe "and teacher is logged in" do
        before (:each) do
          sign_in teacher.user
          # Make sure that the offering is created.
          @own_offerings = [offering, offering_2]
          @other_offerings = [offering_b]
        end

        it "should return list of own offerings only" do
          get :show, id: offering.id
          offering_1_json = JSON.parse(response.body)
          get :show, id: offering_2.id
          offering_2_json = JSON.parse(response.body)

          get :index
          response.status.should eql(200)
          json = JSON.parse(response.body)
          json.should eq [offering_1_json, offering_2_json]
        end

        describe "when class_id param is provided" do
          describe "and teacher is an owner of given class" do
            it "should return list of his offerings for this class" do
              get :show, id: offering.id
              offering_json = JSON.parse(response.body)

              get :index, class_id: clazz.id
              response.status.should eql(200)
              json = JSON.parse(response.body)
              json.should eq [offering_json]
            end
          end

          describe "and teacher is not an owner of given class" do
            it "should return 403 error" do
              get :index, class_id: clazz_b.id
              response.status.should eql(403)
            end
          end
        end

        describe "when user_id param is provided" do
          describe "and teacher is a given user" do
            it "should return list of his all offerings" do
              get :show, id: offering.id
              offering_1_json = JSON.parse(response.body)
              get :show, id: offering_2.id
              offering_2_json = JSON.parse(response.body)


              get :index, user_id: teacher.user.id
              response.status.should eql(200)
              json = JSON.parse(response.body)
              json.should eq [offering_1_json, offering_2_json]
            end
          end

          describe "and teacher is not a given user" do
            it "should return 403 error" do
              get :index, class_id: clazz_b.id
              response.status.should eql(403)
            end
          end
        end
      end

      describe "and admin is logged in" do
        before (:each) do
          sign_in admin_user
          # Make sure that the offering is created.
          @all_offerings = [offering, offering_2, offering_b]
        end

        it "should return list of all the offerings" do
          get :show, id: offering.id
          offering_1_json = JSON.parse(response.body)
          get :show, id: offering_2.id
          offering_2_json = JSON.parse(response.body)
          get :show, id: offering_b.id
          offering_b_json = JSON.parse(response.body)

          get :index
          response.status.should eql(200)
          json = JSON.parse(response.body)
          json.should eq [offering_1_json, offering_2_json, offering_b_json]
        end

        describe "when class_id param is provided" do
          it "should return list of all the offerings for this class" do
            get :show, id: offering.id
            offering_json = JSON.parse(response.body)

            get :index, class_id: clazz.id
            response.status.should eql(200)
            json = JSON.parse(response.body)
            json.should eq [offering_json]
          end
        end

        describe "when user_id param is provided" do
          it "should return list of all user offerings" do
            get :show, id: offering.id
            offering_1_json = JSON.parse(response.body)
            get :show, id: offering_2.id
            offering_2_json = JSON.parse(response.body)

            get :index, user_id: teacher.user.id
            response.status.should eql(200)
            json = JSON.parse(response.body)
            json.should eq [offering_1_json, offering_2_json]
          end
        end
      end
    end

    describe "when some students have run an offering" do
      before (:each) do
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3, open_response_4])
        setup_runnable(runnable, [activity_1, activity_2])

        add_answer_for_student(student_a, offering, open_response_1, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_3, {answer: "Some answer"})
        add_answer_for_student(student_b, offering, open_response_4, {answer: "Some answer"})
      end
      it "returns response which has the same format as #show" do
        get :show, id: offering.id
        show_json = JSON.parse(response.body)

        get :index
        response.status.should eql(200)
        own_json = JSON.parse(response.body)
        own_json.should eq [ show_json ]
      end
    end
  end

  describe "GET #for_class [DEPRECIATED]" do
    describe "when there are multiple teachers, classes and offerings" do
      let(:teacher_b)  { Factory.create(:portal_teacher) }
      let(:clazz_b)    { Factory.create(:portal_clazz, teachers: [teacher_b]) }
      let(:offering_b) { Factory.create(:portal_offering, {clazz: clazz_b, runnable: runnable}) }

      let(:offering_2) { Factory.create(:portal_offering, {clazz: clazz, runnable: runnable}) }

      let(:clazz_2)    { Factory.create(:portal_clazz, teachers: [teacher]) }
      let(:offering_3) { Factory.create(:portal_offering, {clazz: clazz_2, runnable: runnable}) }

      before (:each) do
        sign_in teacher.user
        # Make sure that the offering is created.
        @own_offerings = [offering, offering_2, offering_3]
        @other_offerings = [offering_b]
      end

      it "should return list of all the offerings for the same class" do
        get :show, id: offering.id
        offering_1_json = JSON.parse(response.body)
        get :show, id: offering_2.id
        offering_2_json = JSON.parse(response.body)
        get :show, id: offering_3.id
        offering_3_json = JSON.parse(response.body)

        get :for_class, id: offering.id
        json = JSON.parse(response.body)
        json.should eq [offering_1_json, offering_2_json]

        get :for_class, id: offering_2.id
        json = JSON.parse(response.body)
        json.should eq [offering_1_json, offering_2_json]

        get :for_class, id: offering_3.id
        json = JSON.parse(response.body)
        json.should eq [offering_3_json]

        get :for_class, id: offering_b.id
        response.status.should eql(403) # Different class, no access!
      end
    end
  end

  describe "GET #for_teacher [DEPRECIATED]" do
    describe "when there are multiple teachers, classes and offerings" do
      let(:teacher_b)  { Factory.create(:portal_teacher) }
      let(:clazz_b)    { Factory.create(:portal_clazz, teachers: [teacher_b]) }
      let(:offering_b) { Factory.create(:portal_offering, {clazz: clazz_b, runnable: runnable}) }

      let(:clazz_2)    { Factory.create(:portal_clazz, teachers: [teacher]) }
      let(:offering_2) { Factory.create(:portal_offering, {clazz: clazz_2, runnable: runnable}) }

      before (:each) do
        sign_in teacher.user
        # Make sure that the offering is created.
        @own_offerings = [offering, offering_2]
        @other_offerings = [offering_b]
      end

      it "should return list of all the offerings for the owner of given offering (teacher)" do
        get :show, id: offering.id
        offering_1_json = JSON.parse(response.body)
        get :show, id: offering_2.id
        offering_2_json = JSON.parse(response.body)

        get :for_teacher, id: offering.id
        json = JSON.parse(response.body)
        json.should eq [offering_1_json, offering_2_json]

        get :for_teacher, id: offering_2.id
        json = JSON.parse(response.body)
        json.should eq [offering_1_json, offering_2_json]

        get :for_teacher, id: offering_b.id
        response.status.should eql(403) # different class, no access!
      end
    end
  end
end