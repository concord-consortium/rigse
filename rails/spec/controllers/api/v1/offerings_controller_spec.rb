require 'spec_helper'


describe API::V1::OfferingsController do

  let(:admin_user)        { FactoryBot.generate(:admin_user) }
  let(:manager_user)      { FactoryBot.generate(:manager_user) }
  let(:author_user)       { FactoryBot.generate(:author_user) }
  let(:teacher)           { FactoryBot.create(:portal_teacher) }
  let(:activity_1)        { FactoryBot.create(:external_activity, name: 'Activity 1') }
  let(:activity_2)        { FactoryBot.create(:external_activity, name: 'Activity 2') }
  let(:runnable)          { FactoryBot.create(:external_activity, name: 'Test Sequence') }
  let(:clazz)             { FactoryBot.create(:portal_clazz, name: 'test class', teachers: [teacher], students:[student_a, student_b]) }
  let(:student_a)         { FactoryBot.create(:full_portal_student) }
  let(:student_b)         { FactoryBot.create(:full_portal_student) }
  let(:locked)            { false }
  let(:offering)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable, locked: locked}) }
  let(:slug)              { "test" }
  let(:allow_patterns)    { ".*" }
  let(:rule)              { FactoryBot.create(:admin_auto_external_activity_rule, slug: slug, allow_patterns: allow_patterns, user: author_user) }

  let(:user_offering_active) { true }
  let(:user_offering_locked) { false }
  let(:user_offering_metadata) {
    FactoryBot.create(:user_offering_metadata, user: student_a.user, offering: offering, active: user_offering_active, locked: user_offering_locked)
  }

  before(:each) {
    # This silences warnings in the console when running
    generate_default_settings_with_mocks
  }

  describe "GET #show (+ basic response structure tests)" do

    describe "when there is no offering with given ID" do
      it "returns 404" do
        get :show, params: { id: 123 }
        expect(response.status).to eq 404
      end
    end

    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        get :show, params: { id: offering.id }
        expect(response.status).to eql(403)
      end
    end

    describe "when user is manager" do
      before (:each) do
        sign_in manager_user
      end
      it "returns error 403" do
        get :show, params: { :id => offering.id }
        expect(response.status).to eql(403)
      end
    end

    describe "when user is an admin" do
      before (:each) do
        sign_in admin_user
      end
      it "returns 200 and valid JSON response" do
        get :show, params: { :id => offering.id }
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
          get :show, params: { :id => offering.id }
          expect(response.status).to eq 403
        end
      end

      describe "when the offering belongs to the teachers class" do
        before(:each) do
          sign_in teacher.user
        end
        it "returns 200 and valid JSON response" do
          get :show, params: { :id => offering.id }
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json).not_to eq nil
        end
      end
    end

    describe "when no students have run an offering" do
      before (:each) do
        sign_in teacher.user
        # Ensure that default report is available.
        FactoryBot.create(:default_lara_report)
      end
      it "returns an description of the activity and students list with 0 progress" do
        get :show, params: { id: offering.id }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        json["id"] = offering.id
        expect(json["clazz"]).to eq clazz.name
        expect(json["clazz_hash"]).to eq clazz.class_hash
        expect(json["clazz_id"]).to eq clazz.id
        expect(json["clazz_info_url"]).to eq "http://test.host/api/v1/classes/#{clazz.id}"
        expect(json["activity"]).to eq runnable.name
        expect(json["locked"]).to eq false
        expect(json["report_url"]).to eql report_portal_offering_url(id: offering.id, host: 'test.host')

        expect(json["preview_url"]).to eql external_activity_url(runnable, host: 'test.host', logging: true, format: runnable.run_format)
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

      describe "when offering is locked" do
        let(:locked) { true }

        it "returns locked:true" do
          get :show, params: { id: offering.id }
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json["locked"]).to eq true
        end
      end
    end

    describe "when offering has external reports" do
      let(:external_report_1) { FactoryBot.create(:external_report, name: 'External Report 1', supports_researchers: true) }
      let(:external_report_2) { FactoryBot.create(:external_report, name: 'External Report 2', supports_researchers: false) }

      before (:each) do
        sign_in teacher.user
        runnable.external_reports = [ external_report_1, external_report_2 ]
        runnable.save
      end

      it "returns information about external report" do
        get :show, params: { id: offering.id }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json["external_reports"].length).to eq 2

        expect(json["external_reports"][0]["name"]).to eq "External Report 1"
        expect(json["external_reports"][0]["url"]).to eq portal_external_report_url(id: offering.id, report_id: external_report_1.id, host: 'test.host')
        expect(json["external_reports"][0]["launch_text"]).to eq external_report_1.launch_text
        expect(json["external_reports"][0]["supports_researchers"]).to eq true

        expect(json["external_reports"][1]["name"]).to eq "External Report 2"
        expect(json["external_reports"][1]["url"]).to eq portal_external_report_url(id: offering.id, report_id: external_report_2.id, host: 'test.host')
        expect(json["external_reports"][1]["launch_text"]).to eq external_report_2.launch_text
        expect(json["external_reports"][1]["supports_researchers"]).to eq false
      end
    end

    describe "when add_external_report parameter is provided" do
      let (:external_report) { FactoryBot.create(:external_report) }

      before (:each) do
        sign_in teacher.user
      end

      it "adds this report to the external_reports list" do
        get :show, params: { id: offering.id, add_external_report: external_report.id }
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
        # Make sure that the offering is created.
        @offering = offering
      end
      it "they will get a list of their own offerings with only themselves in the student list" do
        get :index
        expect(response.status).to eql(200)
        json = JSON.parse(response.body)
        expect(json.length).to eq 1
        # student only sees themselves
        expect(json[0]["students"].length).to eq 1
        expect(json[0]["students"][0]["user_id"]).to eq student_a.user.id
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
        # teacher sees both students
        expect(json[0]["students"].length).to eq 2
        expect(json[0]["students"][0]["user_id"]).to eq student_a.user.id
        expect(json[0]["students"][1]["user_id"]).to eq student_b.user.id
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
          get :show, params: { id: offering.id }
          offering_1_json = JSON.parse(response.body)
          get :show, params: { id: offering_2.id }
          offering_2_json = JSON.parse(response.body)

          get :index
          expect(response.status).to eql(200)
          json = JSON.parse(response.body)
          expect(json).to eq [offering_1_json, offering_2_json]
        end

        describe "when class_id param is provided" do
          describe "and teacher is an owner of given class" do
            it "should return list of his offerings for this class" do
              get :show, params: { id: offering.id }
              offering_json = JSON.parse(response.body)

              get :index, params: { class_id: clazz.id }
              expect(response.status).to eql(200)
              json = JSON.parse(response.body)
              expect(json).to eq [offering_json]
            end
          end

          describe "and teacher is not an owner of given class" do
            it "should return 403 error" do
              get :index, params: { class_id: clazz_b.id }
              expect(response.status).to eql(403)
            end
          end
        end

        describe "when user_id param is provided" do
          describe "and teacher is a given user" do
            it "should return list of his all offerings" do
              get :show, params: { id: offering.id }
              offering_1_json = JSON.parse(response.body)
              get :show, params: { id: offering_2.id }
              offering_2_json = JSON.parse(response.body)


              get :index, params: { user_id: teacher.user.id }
              expect(response.status).to eql(200)
              json = JSON.parse(response.body)
              expect(json).to eq [offering_1_json, offering_2_json]
            end
          end

          describe "and teacher is not a given user" do
            it "should return 403 error" do
              get :index, params: { class_id: clazz_b.id }
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
          get :show, params: { id: offering.id }
          offering_1_json = JSON.parse(response.body)
          get :show, params: { id: offering_2.id }
          offering_2_json = JSON.parse(response.body)
          get :show, params: { id: offering_b.id }
          offering_b_json = JSON.parse(response.body)

          get :index
          expect(response.status).to eql(200)
          json = JSON.parse(response.body)
          expect(json).to eq [offering_1_json, offering_2_json, offering_b_json]
        end

        describe "when class_id param is provided" do
          it "should return list of all the offerings for this class" do
            get :show, params: { id: offering.id }
            offering_json = JSON.parse(response.body)

            get :index, params: { class_id: clazz.id }
            expect(response.status).to eql(200)
            json = JSON.parse(response.body)
            expect(json).to eq [offering_json]
          end
        end

        describe "when user_id param is provided" do
          it "should return list of all user offerings" do
            get :show, params: { id: offering.id }
            offering_1_json = JSON.parse(response.body)
            get :show, params: { id: offering_2.id }
            offering_2_json = JSON.parse(response.body)

            get :index, params: { user_id: teacher.user.id }
            expect(response.status).to eql(200)
            json = JSON.parse(response.body)
            expect(json).to eq [offering_1_json, offering_2_json]
          end
        end
      end
    end
  end

  describe "PUT #update" do
    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        put :update, params: { id: offering.id, active: false }
        expect(response.status).to eql(403)
      end
    end

    describe "when user is a student" do
      before (:each) do
        sign_in student_a.user
      end
      it "returns 403 error" do
        put :update, params: { id: offering.id, active: false }
        expect(response.status).to eql(403)
      end
    end

    describe "when user is teacher, but does not own the offering" do
      before (:each) do
        sign_in FactoryBot.create(:portal_teacher).user
      end
      it "returns 403 error" do
        put :update, params: { id: offering.id, active: false }
        expect(response.status).to eql(403)
      end
    end

    describe "when user is teacher and owns the offering" do
      before (:each) do
        sign_in teacher.user
      end

      it "should update basic params of the offering" do
        new_active = !offering.active
        put :update, params: { id: offering.id, active: new_active }
        expect(response.status).to eql(200)
        offering.reload
        expect(offering.active).to eq new_active

        new_locked = !offering.locked
        put :update, params: { id: offering.id, locked: new_locked }
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

          put :update, params: { id: offering_1.id, position: 1 }
          expect(response.status).to eql(200)
          clazz.reload
          expect(clazz.offerings).to eq [ offering_2, offering_1, offering_3 ]

          put :update, params: { id: offering_2.id, position: 2 }
          expect(response.status).to eql(200)
          clazz.reload
          expect(clazz.offerings).to eq [ offering_1, offering_3, offering_2 ]

          put :update, params: { id: offering_3.id, position: 0 }
          expect(response.status).to eql(200)
          clazz.reload
          expect(clazz.offerings).to eq [ offering_3, offering_1, offering_2 ]
        end
      end

      it "should update any existing user metadata" do
        # ensure that user metadata exists with the default values
        user_offering_metadata
        expect(user_offering_metadata.active).to eq true
        expect(user_offering_metadata.locked).to eq false

        # update the offering and check if metadata is updated
        put :update, params: { id: offering.id, active: false, locked: true }
        user_offering_metadata.reload
        expect(user_offering_metadata.active).to eq false
        expect(user_offering_metadata.locked).to eq true
      end
    end
  end

  describe "PUT #update_student_metadata" do
    let (:update_params) { { id: offering.id, user_id: student_a.user.id, active: false, locked: true } }

    describe "when user is not logged in" do
      before (:each) do
        logout_user
      end
      it "returns 403 error" do
        put :update_student_metadata, params: update_params
        expect(response.status).to eql(403)
      end
    end

    describe "when user is a student" do
      before (:each) do
        sign_in student_a.user
      end
      it "returns 403 error" do
        put :update_student_metadata, params: update_params
        expect(response.status).to eql(403)
      end
    end

    describe "when user is teacher, but does not own the offering" do
      before (:each) do
        sign_in FactoryBot.create(:portal_teacher).user
      end
      it "returns 403 error" do
        put :update_student_metadata, params: update_params
        expect(response.status).to eql(403)
      end
    end

    describe "when user is teacher and owns the offering" do
      before (:each) do
        sign_in teacher.user
      end

      it "should update the metadata" do
        # ensure that user metadata exists with the default values
        user_offering_metadata
        expect(user_offering_metadata.active).to eq true
        expect(user_offering_metadata.locked).to eq false

        put :update_student_metadata, params: update_params
        expect(response.status).to eql(200)
        user_offering_metadata.reload
        expect(user_offering_metadata.active).to eq false
        expect(user_offering_metadata.locked).to eq true
      end
    end
  end

  describe "POST create_for_external_activity" do
    describe "as a student" do
      it "should fail" do
        sign_in student_a.user
        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: 'http://test.com' }
        expect(response.status).to eql(403)
      end
    end

    describe "as a teacher" do
      before (:each) do
        sign_in teacher.user
      end

      it "should fail when class_id is not provided" do
        post :create_for_external_activity, params: { name: 'Test', url: 'http://test.com', rule: 'test' }
        expect(JSON.parse(response.body)["message"]).to eq "A class_id is required"
        expect(response.status).to eql(400)
      end

      it "should fail when name is not provided" do
        post :create_for_external_activity, params: { class_id: clazz.id, url: 'http://test.com', rule: 'test' }
        expect(JSON.parse(response.body)["message"]).to eq "A name is required"
        expect(response.status).to eql(400)
      end

      it "should fail when url is not provided" do
        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', rule: 'test' }
        expect(JSON.parse(response.body)["message"]).to eq "An url is required"
        expect(response.status).to eql(400)
      end

      it "should fail when rule is not provided" do
        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: 'http://test.com' }
        expect(JSON.parse(response.body)["message"]).to eq "A rule is required"
        expect(response.status).to eql(400)
      end

      it "should fail when rule doesn't exist" do
        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: 'http://test.com', rule: 'invalid-rule' }
        expect(JSON.parse(response.body)["message"]).to eq "Unable to find invalid-rule rule"
        expect(response.status).to eql(400)
      end

      describe "when rule is provided" do
        let (:allow_patterns) { "https://example.com/*\nhttp://foo.com/*" }

        it "should fail when url doesn't match rule allow_patterns" do
          rule
          post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: 'http://test.com', rule: 'test' }
          expect(JSON.parse(response.body)["message"]).to eq "The URL is not allowed by the rule"
          expect(response.status).to eql(400)
        end

        it "should succeed when url does match rule allow_patterns" do
          rule
          post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: 'http://foo.com/bar', rule: 'test' }
          expect(response.status).to eql(200)
          json = JSON.parse(response.body)
          expect(json["id"]).not_to eq nil
          expect(json["id"]).not_to eq offering.id
          expect(Portal::Offering.find(json["id"]).runnable.url).to eq 'http://foo.com/bar'
        end
      end

      it "should fail when user is not a teacher for the class" do
        other_teacher = FactoryBot.create(:portal_teacher)
        sign_in other_teacher.user
        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: 'http://test.com', rule: 'test' }
        expect(JSON.parse(response.body)["message"]).to eq "You are not a teacher of the specified class"
        expect(response.status).to eql(403)
      end

      it "should create a new offering and external activity if one does not exist" do
        rule
        offering # Make sure that the offering is created.
        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: 'http://test.com', rule: 'test' }
        expect(response.status).to eql(200)
        json = JSON.parse(response.body)
        expect(json["id"]).not_to eq nil
        expect(json["id"]).not_to eq offering.id
        expect(Portal::Offering.find(json["id"]).runnable.url).to eq 'http://test.com'
      end

      it "should create a new offering but not an new external activity if one already exists" do
        offering # Make sure that the offering is created.
        external_activity = ExternalActivity.create!(name: "Existing activity", url: "http://test.com/existing")

        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: external_activity.url, rule: 'test' }
        expect(response.status).to eql(200)
        json = JSON.parse(response.body)
        expect(json["id"]).not_to eq nil
        expect(json["id"]).not_to eq offering.id
        expect(Portal::Offering.find(json["id"]).runnable.id).to eq external_activity.id
        expect(Portal::Offering.find(json["id"]).runnable.url).to eq external_activity.url
      end

      it "should not create a new offering if one already exists" do
        offering # Make sure that the offering is created.
        post :create_for_external_activity, params: { class_id: clazz.id, name: 'Test', url: offering.runnable.url, rule: 'test' }
        expect(response.status).to eql(200)
        json = JSON.parse(response.body)
        expect(json["id"]).not_to eq nil
        expect(json["id"]).to eq offering.id
      end
    end
  end
end
