# encoding: utf-8
require 'spec_helper'

RSpec.describe API::V1::StudentsController, type: :controller do
  let(:student) { FactoryBot.create(:full_portal_student) }

  let(:school)       { FactoryBot.create(:portal_school) }
  let(:teacher_user) { FactoryBot.create(:confirmed_user, :login => "teacher_user") }
  let(:teacher)      { FactoryBot.create(:portal_teacher, :user => teacher_user, :schools => [school]) }
  let(:clazz)        { FactoryBot.create(:portal_clazz, :teachers => [teacher]) }
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
        post :check_password, params
        expect(response.status).to eq(200)
      end
    end

    context "with invalid password" do
      before { params['password'] = 'wrong_password' }
      it "returns error" do
        post :check_password, params
        expect(response.status).to eq(401)
      end
    end

    context "with invalid student id" do
      before { params['id'] = 12321321 }
      it "returns error" do
        post :check_password, params
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#join_class and #confirm_class_word" do

    [:join_class, :confirm_class_word].each do |action|
      it "should fail without a class_word" do
        post action, {}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing class_word parameter"}')
      end

      it "should fail with an unknown class_word" do
        post action, {class_word: "unknown"}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"The class word you provided, \"unknown\", was not valid! Please check with your teacher to ensure you have the correct word."}')
      end
    end

    describe "#join_class" do
      it "should fail for anonymous users" do
        post :join_class, {class_word: clazz.class_word}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be logged in to sign up for a class!"}')
      end

      it "should fail for teacher users" do
        sign_in teacher_user
        post :join_class, {class_word: clazz.class_word}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You can\'t signup for a class while logged in as a teacher!"}')
      end

      it "should succeed for student users" do
        grade_level
        sign_in student_user

        post :join_class, {class_word: clazz.class_word}
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true}')

        expect(student_user.portal_student.clazzes.length).to eq(1)
        expect(student_user.portal_student.clazzes[0]).to eq(clazz)
      end
    end

    describe "#confirm_class_word" do
      it "should succeed with a known classword" do
        post :confirm_class_word, {class_word: clazz.class_word}
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"success":true,"data":{"teacher_name":"joe user"}}')
      end
    end
  end

  describe "#register and #add_to_class" do

    [:register, :add_to_class].each do |action|
      it 'should fail without a clazz_id parameter' do
        post action, {}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing clazz_id parameter"}')
      end

      it 'should fail with an invalid clazz_id parameter' do
        post action, {clazz_id: 0}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Invalid clazz_id: 0"}')
      end
    end
  end

  describe '#register' do
    let (:password_confirmation) { "testtest" }
    let (:user_parameters) { {first_name: "Test", last_name: "Testerson", password: "testtest", password_confirmation: password_confirmation } }
    let(:admin_settings) { FactoryBot.create(:admin_settings, :allow_default_class => false) }

    before :each do
      sign_in teacher_user
    end

    it 'should fail without a user parameter' do
      post :register, {clazz_id: clazz.id}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing user parameters"}')
    end

    it 'should fail when the teacher is not in the class' do
      post :register, {clazz_id: clazz2.id, user: user_parameters}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be a teacher of the class to register and add students"}')
    end

    describe 'with a bad user parameters ' do
      it 'should fail when the first_name is missing' do
        post :register, {clazz_id: clazz.id, user: {}}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing user first_name parameter"}')
      end

      it 'should fail when the last_name is missing' do
        post :register, {clazz_id: clazz.id, user: {first_name: "Test"}}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing user last_name parameter"}')
      end

      it 'should fail when the password is missing' do
        post :register, {clazz_id: clazz.id, user: {first_name: "Test", last_name: "Testerson"}}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Password can\'t be blank. Password confirmation can\'t be blank"}')
      end
    end

    describe 'with a bad password confirmation' do
      let (:password_confirmation) { "testtest!" }

      it 'should fail when the passwords do not match' do
        post :register, {clazz_id: clazz.id, user: user_parameters}
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Password confirmation doesn\'t match Password"}')
      end
    end

    it 'should succeed' do
      admin_settings
      post :register, {clazz_id: clazz.id, user: user_parameters}
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

  describe '#add_to_class' do
    it 'should fail without a student_id parameter' do
      post :add_to_class, {clazz_id: clazz.id}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing student_id parameter"}')
    end

    it 'should fail with and invalid student_id parameter' do
      post :add_to_class, {clazz_id: clazz.id, student_id: 0}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Invalid student_id: 0"}')
    end

    it 'should fail when the teacher is not in the class' do
      sign_in teacher_user
      post :add_to_class, {clazz_id: clazz2.id, student_id: student.id}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be a teacher of the class to add students"}')
    end

    it 'should succeed' do
      sign_in teacher_user
      expect(clazz.students.include? student).to eq false
      post :add_to_class, {clazz_id: clazz.id, student_id: student.id}
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('{"success":true}')
      expect(clazz.students.include? student).to eq true
    end
  end

  describe '#remove_from_class' do
    it 'should fail without a student_clazz_id parameter' do
      post :remove_from_class, {}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing student_clazz_id parameter"}')
    end

    it 'should fail with an invalid student_clazz_id parameter' do
      post :remove_from_class, {student_clazz_id: 0}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Invalid student_clazz_id: 0"}')
    end

    it 'should fail when the teacher is not in the class' do
      sign_in teacher_user
      post :remove_from_class, {student_clazz_id: student_clazz2.id}
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"You must be a teacher of the class to remove students"}')
    end

    it 'should succeed' do
      sign_in teacher_user
      expect { student_clazz.reload }.not_to raise_error
      post :remove_from_class, {student_clazz_id: student_clazz.id}
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('{"success":true}')
      expect { student_clazz.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#check_class_word' do
    it 'GET check_class_word' do
      get :check_class_word, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end

end
