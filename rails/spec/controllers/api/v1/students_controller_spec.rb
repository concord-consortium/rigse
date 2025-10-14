# encoding: utf-8
require 'spec_helper'
require 'uri'

RSpec.describe API::V1::StudentsController, type: :controller do
  let(:student) { FactoryBot.create(:full_portal_student) }

  let(:school)       { FactoryBot.create(:portal_school) }
  let(:teacher_user) { FactoryBot.create(:confirmed_user, :login => "teacher_user") }
  let(:teacher)      { FactoryBot.create(:portal_teacher, :user => teacher_user, :schools => [school]) }
  let(:clazz)        { FactoryBot.create(:portal_clazz, :teachers => [teacher]) }
  let(:clazz_with_student) { FactoryBot.create(:portal_clazz, :teachers => [teacher], :students => [student]) }
  let(:student_user) { FactoryBot.create(:confirmed_user, :login => "student_user") }
  let(:grade_level)  { FactoryBot.create(:grade_level, :name => "9") }

  let(:teacher_user2)  { FactoryBot.create(:confirmed_user, :login => "teacher_user2") }
  let(:teacher2)       { FactoryBot.create(:portal_teacher, :user => teacher_user2, :schools => [school]) }
  let(:clazz2)         { FactoryBot.create(:portal_clazz, :teachers => [teacher2]) }

  let(:student_clazz)  { FactoryBot.create(:portal_student_clazz, :clazz => clazz) }
  let(:student_clazz2) { FactoryBot.create(:portal_student_clazz, :clazz => clazz2) }

  describe "POST #check_password" do
    let(:params) do
      {
        'id' => student.id,
        'password' => 'password'
      }
    end

    context "with valid password" do
      it "returns ok" do
        post :check_password, params: params
        expect(response.status).to eq(200)
      end
    end

    context "with invalid password" do
      before { params['password'] = 'wrong_password' }
      it "returns error" do
        post :check_password, params: params
        expect(response.status).to eq(401)
      end
    end

    context "with invalid student id" do
      before { params['id'] = 12321321 }
      it "returns error" do
        post :check_password, params: params
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#join_class and #confirm_class_word" do

    [:join_class, :confirm_class_word].each do |action|
      it "should fail without a class_word" do
        post action
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing class_word parameter"}')
      end

      it "should fail with an unknown class_word" do
        post action, params: { class_word: "unknown" }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"The class word you provided, \"unknown\", was not valid! Please check with your teacher to ensure you have the correct word."}')
      end
    end

    describe "#join_class" do
      it "should fail for anonymous users" do
        post :join_class, params: { class_word: clazz.class_word }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be logged in to sign up for a class!"}')
      end

      it "should fail for teacher users" do
        sign_in teacher_user
        post :join_class, params: { class_word: clazz.class_word }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You can\'t signup for a class while logged in as a teacher!"}')
      end

      it "should succeed for student users" do
        grade_level
        sign_in student_user

        post :join_class, params: { class_word: clazz.class_word }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')

        expect(student_user.portal_student.clazzes.length).to eq(1)
        expect(student_user.portal_student.clazzes[0]).to eq(clazz)
      end
    end

    describe "#confirm_class_word" do
      it "should succeed with a known classword" do
        post :confirm_class_word, params: { class_word: clazz.class_word }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true,"data":{"teacher_name":"joe user"}}')
      end
    end
  end

  # describe "#register and #add_to_class" do

  #   [:register, :add_to_class].each do |action|
  #     it 'should fail without a clazz_id parameter' do
  #       post action
  #       expect(response).to have_http_status(:bad_request)
  #       expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing clazz_id parameter"}')
  #     end

  #     it 'should fail with an invalid clazz_id parameter' do
  #       post action, params: { clazz_id: 0 }
  #       expect(response).to have_http_status(:bad_request)
  #       expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Invalid clazz_id: 0"}')
  #     end
  #   end
  # end

  describe '#register' do
    let (:password_confirmation) { "testtest" }
    let (:user_parameters) { {first_name: "Test", last_name: "Testerson", password: "testtest", password_confirmation: password_confirmation } }
    let(:admin_settings) { FactoryBot.create(:admin_settings, :allow_default_class => false) }

    before :each do
      sign_in teacher_user
    end

    it 'should fail without a user parameter' do
      post :register, params: { clazz_id: clazz.id }
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing user parameters"}')
    end

    it 'should fail when the teacher is not in the class' do
      post :register, params: { clazz_id: clazz2.id, user: user_parameters }
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be a teacher of the class to register and add students"}')
    end

    describe 'with a bad user parameters ' do
      it 'should fail when the first_name is missing' do
        post :register, params: { clazz_id: clazz.id, user: {last_name: "Testerson"} }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing user first_name parameter"}')
      end

      it 'should fail when the last_name is missing' do
        post :register, params: { clazz_id: clazz.id, user: {first_name: "Test"} }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing user last_name parameter"}')
      end

      it 'should fail when the password is missing' do
        post :register, params: { clazz_id: clazz.id, user: {first_name: "Test", last_name: "Testerson"} }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Password can\'t be blank."}')
      end

      it 'should fail when the password confirmation is missing' do
        post :register, params: { clazz_id: clazz.id, user: {first_name: "Test", last_name: "Testerson", password: "password"} }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Password confirmation can\'t be blank."}')
      end
    end

    describe 'with a bad password confirmation' do
      let (:password_confirmation) { "testtest!" }

      it 'should fail when the passwords do not match' do
        post :register, params: { clazz_id: clazz.id, user: user_parameters }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Password confirmation doesn\'t match Password"}')
      end
    end

    it 'should succeed' do
      admin_settings
      post :register, params: { clazz_id: clazz.id, user: user_parameters }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["success"]).to eq true

      data = json["data"]

      user = data["user"]
      expect(user["id"]).not_to eq nil
      expect(user["login"]).to eq "ttesterson"
      expect(user["email"]).not_to eq nil

      student = data["student"]
      expect(student["id"]).not_to eq nil

      _clazz = data["clazz"]
      expect(_clazz["id"]).to eq clazz.id
    end
  end

  # This was disabled for security before, because any teacher could add any student
  # to their class as long as they knew or guessed the student id.
  # Now only students that the current user can view are allowed to be added to classes
  # the current user can manage.
  describe '#add_to_class' do
    it 'should fail without a student_id parameter' do
      sign_in teacher_user
      post :add_to_class, params: { clazz_id: clazz.id }
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing student_id parameter"}')
    end

    it 'should fail with and invalid student_id parameter' do
      sign_in teacher_user
      post :add_to_class, params: { clazz_id: clazz.id, student_id: 0 }
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Invalid student_id: 0"}')
    end

    describe 'it should fail if the current user' do
      it 'is not a teacher of the class' do
        sign_in teacher_user
        post :add_to_class, params: { clazz_id: clazz2.id, student_id: student.id }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq('{"success":false,"message":"Not authorized"}')
      end

      it 'is a teacher that does not have this student in any classes' do
        new_student = FactoryBot.create(:full_portal_student) # create a student that is not accessible by the teacher
        sign_in teacher_user
        post :add_to_class, params: { clazz_id: clazz.id, student_id: new_student.id }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq('{"success":false,"message":"Not authorized"}')
      end

      it 'is a project admin that is not associated with the class or with the student' do
        project_admin = FactoryBot.create(:confirmed_user, :login => "project_admin")
        project = FactoryBot.create(:project)
        project_admin.add_role_for_project('admin', project)
        sign_in project_admin
        post :add_to_class, params: { clazz_id: clazz.id, student_id: student.id }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq('{"success":false,"message":"Not authorized"}')
      end
    end

    describe 'should succeed if the current user' do
      it 'is a teacher of another class of the student' do
        sign_in teacher_user
        expect(clazz_with_student.students.include? student).to eq true
        expect(clazz.students.include? student).to eq false
        post :add_to_class, params: { clazz_id: clazz.id, student_id: student.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')
        expect(clazz.students.include? student).to eq true
      end

      it 'is an admin' do
        admin_user = FactoryBot.generate(:admin_user)
        sign_in admin_user
        expect(clazz.students.include? student).to eq false
        post :add_to_class, params: { clazz_id: clazz.id, student_id: student.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')
        expect(clazz.students.include? student).to eq true
      end

      it 'is a project admin associated with the class and with the student' do
        project_admin = FactoryBot.create(:confirmed_user, :login => "project_admin")
        project = FactoryBot.create(:project)
        project_admin.add_role_for_project('admin', project)
        cohort = FactoryBot.create(:admin_cohort, :project => project)
        teacher.cohorts << cohort
        # because the student is in another class of the teacher that associates
        # the student with the project_admin
        expect(clazz_with_student.students.include? student).to eq true

        sign_in project_admin
        expect(clazz.students.include? student).to eq false
        post :add_to_class, params: { clazz_id: clazz.id, student_id: student.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')
        expect(clazz.students.include? student).to eq true
      end
    end
  end

  describe '#remove_from_class' do
    it 'should fail without a student_clazz_id parameter' do
      post :remove_from_class
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing student_clazz_id parameter"}')
    end

    it 'should fail with an invalid student_clazz_id parameter' do
      post :remove_from_class, params: { student_clazz_id: 0 }
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Invalid student_clazz_id: 0"}')
    end

    describe 'it should fail if the current user' do
      it 'is not a teacher of the class' do
        sign_in teacher_user
        post :remove_from_class, params: { student_clazz_id: student_clazz2.id }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq('{"success":false,"message":"Not authorized"}')
      end

      it 'is a project admin that is not associated with the class or with the student' do
        project_admin = FactoryBot.create(:confirmed_user, :login => "project_admin")
        project = FactoryBot.create(:project)
        project_admin.add_role_for_project('admin', project)
        sign_in project_admin
        post :remove_from_class, params: { student_clazz_id: student_clazz.id }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq('{"success":false,"message":"Not authorized"}')
      end
    end

    describe 'should succeed if the current user' do
      it 'is a teacher of the class' do
        clazz.students << student
        sign_in teacher_user
        local_student_clazz = clazz.student_clazzes.find_by(student_id: student.id)
        post :remove_from_class, params: { student_clazz_id: local_student_clazz.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')
        expect { local_student_clazz.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(clazz.students.include? student).to eq false
      end

      it 'is an admin' do
        admin_user = FactoryBot.generate(:admin_user)
        sign_in admin_user
        post :remove_from_class, params: { student_clazz_id: student_clazz.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')
        expect { student_clazz.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'is a project admin associated with the class and with the student' do
        project_admin = FactoryBot.create(:confirmed_user, :login => "project_admin")
        project = FactoryBot.create(:project)
        project_admin.add_role_for_project('admin', project)
        cohort = FactoryBot.create(:admin_cohort, :project => project)
        teacher.cohorts << cohort

        sign_in project_admin
        post :remove_from_class, params: { student_clazz_id: student_clazz.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')
        expect { student_clazz.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#check_class_word' do
    it 'GET check_class_word' do
      get :check_class_word

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe '#get_feedback_metadata' do
    bearer_token = "abc123"

    before :each do
      student_user.portal_student = student

      stub_const("ENV", ENV.to_h.merge(
        "REPORT_SERVICE_URL" => "http://example.com",
        "REPORT_SERVICE_SOURCE" => "authoring.example.org",
        "REPORT_SERVICE_BEARER_TOKEN" => bearer_token
      ))
    end

    it 'should fail without a user' do
      get :get_feedback_metadata
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be a student to use this endpoint"}')
    end

    it 'should fail when the user is not a student' do
      sign_in teacher_user
      get :get_feedback_metadata
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be a student to use this endpoint"}')
    end

    it 'should fail when the report service URL is not configured' do
      stub_const("ENV", ENV.to_h.merge("REPORT_SERVICE_URL" => nil))
      sign_in student_user
      get :get_feedback_metadata
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Feedback metadata URL not configured"}')
    end

    it 'should fail when the report service source is not configured' do
      stub_const("ENV", ENV.to_h.merge("REPORT_SERVICE_SOURCE" => nil))
      sign_in student_user
      get :get_feedback_metadata
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Feedback metadata source not configured"}')
    end

    it 'should fail when the report service bearer token is not configured' do
      stub_const("ENV", ENV.to_h.merge("REPORT_SERVICE_BEARER_TOKEN" => nil))
      sign_in student_user
      get :get_feedback_metadata
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Feedback metadata bearer token not configured"}')
    end

    it 'returns feedback metadata for signed-in student' do
      sign_in student_user

      stubbed_response = { "success": true, "result": { "foo": "bar" } }.to_json
      expected_query = URI.encode_www_form(
        source: ENV['REPORT_SERVICE_SOURCE'],
        platform_id: APP_CONFIG[:site_url] || "http://learn.concord.org",
        platform_student_id: student_user.id
      )
      stub_request(:get, "#{ENV['REPORT_SERVICE_URL']}/student_feedback_metadata")
        .with(query: expected_query, headers: {"Authorization"=>"Bearer #{bearer_token}"})
        .to_return(status: 200, body: stubbed_response, headers: { "Content-Type" => "application/json" })

      get :get_feedback_metadata
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(stubbed_response)
    end

  end

end
