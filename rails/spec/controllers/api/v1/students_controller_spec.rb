# encoding: utf-8
require 'spec_helper'

RSpec.describe API::V1::StudentsController, type: :controller do
  let(:student) { FactoryBot.create(:full_portal_student) }

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
    let(:school)       { FactoryBot.create(:portal_school) }
    let(:teacher_user) { FactoryBot.create(:confirmed_user, :login => "teacher_user") }
    let(:teacher)      { FactoryBot.create(:portal_teacher, :user => teacher_user, :schools => [school]) }
    let(:clazz)        { FactoryBot.create(:portal_clazz, :teachers => [teacher]) }
    let(:student_user) { FactoryBot.create(:confirmed_user, :login => "student_user") }
    let(:grade_level)  { FactoryBot.create(:grade_level, :name => "9") }

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
