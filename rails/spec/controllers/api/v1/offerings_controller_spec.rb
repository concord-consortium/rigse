require 'spec_helper'
include ReportLearnerSpecHelper


describe API::V1::OfferingsController do

  let(:admin_user)        { FactoryBot.generate(:admin_user) }
  let(:manager_user)      { FactoryBot.generate(:manager_user) }
  let(:teacher)           { FactoryBot.create(:portal_teacher) }
  let(:open_response_1)   { FactoryBot.create(:open_response) }
  let(:open_response_2)   { FactoryBot.create(:open_response) }
  let(:open_response_3)   { FactoryBot.create(:open_response) }
  let(:open_response_4)   { FactoryBot.create(:open_response) }
  let(:activity_1)        { FactoryBot.create(:activity, name: 'Activity 1') }
  let(:activity_2)        { FactoryBot.create(:activity, name: 'Activity 2') }
  let(:runnable)          { FactoryBot.create(:external_activity, name: 'Test Sequence') }
  let(:clazz)             { FactoryBot.create(:portal_clazz, name: 'test class', teachers: [teacher], students:[student_a, student_b]) }
  let(:student_a)         { FactoryBot.create(:full_portal_student) }
  let(:student_b)         { FactoryBot.create(:full_portal_student) }
  let(:offering)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable}) }

  def setup_activity(activity, embeddables)
    section = FactoryBot.create(:section)
    page = FactoryBot.create(:page)
    embeddables.each { |e| page.add_embeddable(e) }
    section.pages << page
    activity.sections << section
    activity.save
  end

  def setup_runnable(runnable, activities)
    investigation = FactoryBot.create(:investigation)
    activities.each { |a| investigation.activities << a }
    investigation.save
    runnable.template = investigation
    runnable.save
  end

  def add_answer(offering, student, question)
    learner = Portal::Learner.where(offering_id: offering.id, student_id: student.id ).first_or_create
    add_answer_for_learner(learner, question, {answer: "Some answer"})
    learner.report_learner.update_answers
    learner.report_learner.save!
  end

  before(:each) {
    # This silences warnings in the console when running
    generate_default_settings_and_jnlps_with_mocks
  }

  describe "GET #show (+ basic response structure tests)" do

    describe "when there is no offering with given ID" do
      it "returns 404" do
        get :show, id: 123
        expect(response.status).to eq 404
      end
    end

    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        get :show, id: offering.id
        expect(response.status).to eql(403)
      end
    end

    describe "when user is manager" do
      before (:each) do
        sign_in manager_user
      end
      it "returns error 403" do
        get :show, :id => offering.id
        expect(response.status).to eql(403)
      end
    end

    describe "when user is an admin" do
      before (:each) do
        sign_in admin_user
      end
      it "returns 200 and valid JSON response" do
        get :show, :id => offering.id
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json).not_to eq nil
      end
    end

    describe "when user is a teacher" do
      describe "when the offering doesn't belong to the teachers class" do
        before(:each) do
          other_teacher = FactoryBot.create(:portal_teacher)
          sign_in other_teacher.user
        end
        it "returns error 403" do
          get :show, :id => offering.id
          expect(response.status).to eq 403
        end
      end

      describe "when the offering belongs to the teachers class" do
        before(:each) do
          sign_in teacher.user
        end
        it "returns 200 and valid JSON response" do
          get :show, :id => offering.id
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json).not_to eq nil
        end
      end
    end

    describe "when no students have run an offering" do
      before (:each) do
        sign_in teacher.user
        setup_activity(activity_1, [open_response_1, open_response_2])
        setup_activity(activity_2, [open_response_3])
        setup_runnable(runnable, [activity_1, activity_2])
        # Ensure that default report is available.
        FactoryBot.create(:default_lara_report)
      end
      it "returns an description of the activity and students list with 0 progress" do
        get :show, id: offering.id
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        json["id"] = offering.id
        expect(json["clazz"]).to eq clazz.name
        expect(json["clazz_hash"]).to eq clazz.class_hash
        expect(json["clazz_id"]).to eq clazz.id
        expect(json["clazz_info_url"]).to eq "http://test.host/api/v1/classes/#{clazz.id}"
        expect(json["activity"]).to eq runnable.name
        expect(json["report_url"]).to eql report_portal_offering_url(id: offering.id, host: 'test.host')

        expect(json["preview_url"]).to eql external_activity_url(runnable, {logging: true, format: runnable.run_format})
        expect(json["students"].length).to eq 2

        student1 = json["students"][0]
        expect(student1["first_name"]).to eq student_a.user.first_name
        expect(student1["last_name"]).to eq student_a.user.last_name
        expect(student1["started_activity"]).to eq false
        expect(student1["last_run"]).to eq nil
        expect(student1["total_progress"]).to eq 0
        expect(student1["detailed_progress"]).to eq nil

        student2 = json["students"][1]
        expect(student2["first_name"]).to eq student_b.user.first_name
        expect(student2["last_name"]).to eq student_b.user.last_name
        expect(student2["started_activity"]).to eq false
        expect(student2["last_run"]).to eq nil
        expect(student2["total_progress"]).to eq 0
        expect(student2["detailed_progress"]).to eq nil
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
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        student1 = json["students"][0]
        expect(student1["started_activity"]).to eq true
        expect(student1["last_run"]).not_to eq nil
        expect(student1["total_progress"]).to eq 25
        expect(student1["detailed_progress"][0]["activity_name"]).to eq activity_1.name
        expect(student1["detailed_progress"][0]["progress"]).to eq 50
        expect(student1["detailed_progress"][1]["activity_name"]).to eq activity_2.name
        expect(student1["detailed_progress"][1]["progress"]).to eq 0

        student2 = json["students"][1]
        expect(student2["started_activity"]).to eq false
        expect(student2["last_run"]).to eq nil
        expect(student2["total_progress"]).to eq 0
        expect(student2["detailed_progress"]).to eq nil
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
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        student1 = json["students"][0]
        expect(student1["started_activity"]).to eq true
        expect(student1["last_run"]).not_to eq nil
        expect(student1["total_progress"]).to eq 25
        expect(student1["detailed_progress"][0]["activity_name"]).to eq activity_1.name
        expect(student1["detailed_progress"][0]["progress"]).to eq 50
        expect(student1["detailed_progress"][1]["activity_name"]).to eq activity_2.name
        expect(student1["detailed_progress"][1]["progress"]).to eq 0

        student2 = json["students"][1]
        expect(student2["started_activity"]).to eq true
        expect(student2["last_run"]).not_to eq nil
        expect(student2["total_progress"]).to eq 50
        expect(student2["detailed_progress"][0]["activity_name"]).to eq activity_1.name
        expect(student2["detailed_progress"][0]["progress"]).to eq 0
        expect(student2["detailed_progress"][1]["activity_name"]).to eq activity_2.name
        expect(student2["detailed_progress"][1]["progress"]).to eq 100
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
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        student1 = json["students"][0]
        expect(student1["started_activity"]).to eq true
        expect(student1["last_run"]).not_to eq nil
        expect(student1["total_progress"]).to eq 100
        expect(student1["detailed_progress"][0]["activity_name"]).to eq activity_1.name
        expect(student1["detailed_progress"][0]["progress"]).to eq 100
        expect(student1["detailed_progress"][1]["activity_name"]).to eq activity_2.name
        expect(student1["detailed_progress"][1]["progress"]).to eq 100


        student2 = json["students"][1]
        expect(student2["started_activity"]).to eq true
        expect(student2["last_run"]).not_to eq nil
        expect(student2["total_progress"]).to eq 100
        expect(student2["detailed_progress"][0]["activity_name"]).to eq activity_1.name
        expect(student2["detailed_progress"][0]["progress"]).to eq 100
        expect(student2["detailed_progress"][1]["activity_name"]).to eq activity_2.name
        expect(student2["detailed_progress"][1]["progress"]).to eq 100
      end
    end

    describe "when offering has an external report" do
      let (:external_report) { FactoryBot.create(:external_report) }

      before (:each) do
        sign_in teacher.user
        runnable.external_reports = [ external_report ]
        runnable.save
      end

      it "returns information about external report" do
        get :show, id: offering.id
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json["external_reports"][0]).not_to eq nil
        expect(json["external_reports"][0]["url"]).to eq portal_external_report_url(id: offering.id, report_id: external_report.id, host: 'test.host')
        expect(json["external_reports"][0]["launch_text"]).to eq external_report.launch_text
      end
    end

    describe "when add_external_report parameter is provided" do
      let (:external_report) { FactoryBot.create(:external_report) }

      before (:each) do
        sign_in teacher.user
      end

      it "adds this report to the external_reports list" do
        get :show, id: offering.id, add_external_report: external_report.id
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json["external_reports"][0]).not_to eq nil
        expect(json["external_reports"][0]["url"]).to eq portal_external_report_url(id: offering.id, report_id: external_report.id, host: 'test.host')
        expect(json["external_reports"][0]["launch_text"]).to eq external_report.launch_text
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
        expect(response.status).to eql(403)
      end
    end

    describe "when user is a student" do
      before (:each) do
        sign_in student_a.user
      end
      it "returns 403 error" do
        get :index
        expect(response.status).to eql(403)
      end
    end

    describe "when user is a teacher, but have no offerings" do
      before (:each) do
        sign_in teacher.user
      end
      it "returns an empty array" do
        get :index
        expect(response.status).to eql(200)
        json = JSON.parse(response.body)
        expect(json).to eq []
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
        expect(response.status).to eql(200)
        json = JSON.parse(response.body)
        expect(json.length).to eq 1
      end
    end

    describe "when there are multiple teachers, classes and offerings" do
      let(:teacher_b)  { FactoryBot.create(:portal_teacher) }
      let(:clazz_b)    { FactoryBot.create(:portal_clazz, teachers: [teacher_b]) }
      let(:offering_b) { FactoryBot.create(:portal_offering, {clazz: clazz_b, runnable: runnable}) }

      let(:clazz_2)    { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
      let(:offering_2) { FactoryBot.create(:portal_offering, {clazz: clazz_2, runnable: runnable}) }

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
          expect(response.status).to eql(200)
          json = JSON.parse(response.body)
          expect(json).to eq [offering_1_json, offering_2_json]
        end

        describe "when class_id param is provided" do
          describe "and teacher is an owner of given class" do
            it "should return list of his offerings for this class" do
              get :show, id: offering.id
              offering_json = JSON.parse(response.body)

              get :index, class_id: clazz.id
              expect(response.status).to eql(200)
              json = JSON.parse(response.body)
              expect(json).to eq [offering_json]
            end
          end

          describe "and teacher is not an owner of given class" do
            it "should return 403 error" do
              get :index, class_id: clazz_b.id
              expect(response.status).to eql(403)
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
              expect(response.status).to eql(200)
              json = JSON.parse(response.body)
              expect(json).to eq [offering_1_json, offering_2_json]
            end
          end

          describe "and teacher is not a given user" do
            it "should return 403 error" do
              get :index, class_id: clazz_b.id
              expect(response.status).to eql(403)
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
          expect(response.status).to eql(200)
          json = JSON.parse(response.body)
          expect(json).to eq [offering_1_json, offering_2_json, offering_b_json]
        end

        describe "when class_id param is provided" do
          it "should return list of all the offerings for this class" do
            get :show, id: offering.id
            offering_json = JSON.parse(response.body)

            get :index, class_id: clazz.id
            expect(response.status).to eql(200)
            json = JSON.parse(response.body)
            expect(json).to eq [offering_json]
          end
        end

        describe "when user_id param is provided" do
          it "should return list of all user offerings" do
            get :show, id: offering.id
            offering_1_json = JSON.parse(response.body)
            get :show, id: offering_2.id
            offering_2_json = JSON.parse(response.body)

            get :index, user_id: teacher.user.id
            expect(response.status).to eql(200)
            json = JSON.parse(response.body)
            expect(json).to eq [offering_1_json, offering_2_json]
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
        expect(response.status).to eql(200)
        own_json = JSON.parse(response.body)
        expect(own_json).to eq [ show_json ]
      end
    end
  end

  describe "PUT #update" do
    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        put :update, id: offering.id, active: false
        expect(response.status).to eql(403)
      end
    end

    describe "when user is a student" do
      before (:each) do
        sign_in student_a.user
      end
      it "returns 403 error" do
        put :update, id: offering.id, active: false
        expect(response.status).to eql(403)
      end
    end

    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        put :update, id: offering.id, active: false
        expect(response.status).to eql(403)
      end
    end

    describe "when user is teacher, but does not own the offering" do
      before (:each) do
        sign_in FactoryBot.create(:portal_teacher).user
      end
      it "returns 403 error" do
        put :update, id: offering.id, active: false
        expect(response.status).to eql(403)
      end
    end

    describe "when user is teacher and owns the offering" do
      before (:each) do
        sign_in teacher.user
      end

      it "should update basic params of the offering" do
        new_active = !offering.active
        put :update, id: offering.id, active: new_active
        expect(response.status).to eql(200)
        offering.reload
        expect(offering.active).to eq new_active

        new_locked = !offering.locked
        put :update, id: offering.id, locked: new_locked
        expect(response.status).to eql(200)
        offering.reload
        expect(offering.locked).to eq new_locked
      end

      describe "when there are multiple offerings" do
        let(:offering_1) { offering }
        let(:offering_2) { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable}) }
        let(:offering_3) { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable}) }

        it "should let user reorder them" do
          expect(clazz.offerings).to eq [ offering_1, offering_2, offering_3 ]

          put :update, id: offering_1.id, position: 1
          expect(response.status).to eql(200)
          clazz.reload
          expect(clazz.offerings).to eq [ offering_2, offering_1, offering_3 ]

          put :update, id: offering_2.id, position: 2
          expect(response.status).to eql(200)
          clazz.reload
          expect(clazz.offerings).to eq [ offering_1, offering_3, offering_2 ]

          put :update, id: offering_3.id, position: 0
          expect(response.status).to eql(200)
          clazz.reload
          expect(clazz.offerings).to eq [ offering_3, offering_1, offering_2 ]
        end
      end
    end
  end

  describe "GET #for_class [DEPRECIATED]" do
    describe "when there are multiple teachers, classes and offerings" do
      let(:teacher_b)  { FactoryBot.create(:portal_teacher) }
      let(:clazz_b)    { FactoryBot.create(:portal_clazz, teachers: [teacher_b]) }
      let(:offering_b) { FactoryBot.create(:portal_offering, {clazz: clazz_b, runnable: runnable}) }

      let(:offering_2) { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable}) }

      let(:clazz_2)    { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
      let(:offering_3) { FactoryBot.create(:portal_offering, {clazz: clazz_2, runnable: runnable}) }

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
        expect(json).to eq [offering_1_json, offering_2_json]

        get :for_class, id: offering_2.id
        json = JSON.parse(response.body)
        expect(json).to eq [offering_1_json, offering_2_json]

        get :for_class, id: offering_3.id
        json = JSON.parse(response.body)
        expect(json).to eq [offering_3_json]

        get :for_class, id: offering_b.id
        expect(response.status).to eql(403) # Different class, no access!
      end
    end
  end

  describe "GET #for_teacher [DEPRECIATED]" do
    describe "when there are multiple teachers, classes and offerings" do
      let(:teacher_b)  { FactoryBot.create(:portal_teacher) }
      let(:clazz_b)    { FactoryBot.create(:portal_clazz, teachers: [teacher_b]) }
      let(:offering_b) { FactoryBot.create(:portal_offering, {clazz: clazz_b, runnable: runnable}) }

      let(:clazz_2)    { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
      let(:offering_2) { FactoryBot.create(:portal_offering, {clazz: clazz_2, runnable: runnable}) }

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
        expect(json).to eq [offering_1_json, offering_2_json]

        get :for_teacher, id: offering_2.id
        json = JSON.parse(response.body)
        expect(json).to eq [offering_1_json, offering_2_json]

        get :for_teacher, id: offering_b.id
        expect(response.status).to eql(403) # different class, no access!
      end
    end
  end
end
