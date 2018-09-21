# encoding: utf-8
require 'spec_helper'

describe API::V1::TeachersController do
  let(:school) { FactoryBot.create(:portal_school) }
  let(:teacher_user)    { FactoryBot.create(:confirmed_user, :login => "teacher_user") }

  let(:teacher_params) do
    {
      first_name: "teacher",
      last_name: "doe",
      login: "teacher_user",
      password: "testingxxy",
      email: "teacher@concord.org",
      school_id: school.id
    }
  end

  let(:school_params) do
    {
      name: "test school",
      zipcode: "88001",
      country_id: 1
    }
  end

  let(:teacher_and_new_school_params) do
    {
      first_name: "teacher",
      last_name: "doe",
      login: "teacher_user",
      password: "testingxxy",
      email: "teacher@concord.org",
      school_name: school_params[:name],
      zipcode: school_params[:zipcode],
      country_id: school_params[:country_id]
    }
  end

  describe "POST #create" do
    context "with valid teacher params" do
      it "creates a new teacher" do
        old_teachers_count = Portal::Teacher.count
        post :create, teacher_params
        expect(response.status).to eq(201)
        expect(Portal::Teacher.count).to eq(old_teachers_count + 1)
      end
    end

    context "without school_id and without new school params" do
      it "returns an error" do
        old_teachers_count = Portal::Teacher.count
        post :create, teacher_params.except(:school_id)
        expect(response.status).to eq(400)
        expect(Portal::Teacher.count).to eq(old_teachers_count)
      end
    end

    context "without school_id and with new school params" do
      context "when both teacher and school params are valid" do
        it "creates a new teacher and a new school" do
          old_teachers_count = Portal::Teacher.count
          old_schools_count = Portal::School.count
          post :create, teacher_and_new_school_params
          expect(response.status).to eq(201)
          expect(Portal::Teacher.count).to eq(old_teachers_count + 1)
          expect(Portal::School.count).to eq(old_schools_count + 1)
        end
      end

      context "when teacher params are invalid" do
        it "returns an error" do
          old_teachers_count = Portal::Teacher.count
          old_schools_count = Portal::School.count
          post :create, teacher_and_new_school_params.except(:login)
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)['message']['login']).not_to be_nil
          expect(Portal::Teacher.count).to eq(old_teachers_count)
          expect(Portal::School.count).to eq(old_schools_count)
        end
      end

      context "when school params are invalid" do
        it "returns an error" do
          old_teachers_count = Portal::Teacher.count
          old_schools_count = Portal::School.count
          post :create, teacher_and_new_school_params.except(:school_name)
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)['message']['school_id']).not_to be_nil
          expect(Portal::Teacher.count).to eq(old_teachers_count)
          expect(Portal::School.count).to eq(old_schools_count)
        end
      end

      context "when there's already a school with the same params" do
        it "a teacher is created but school is reused" do
          Portal::School.create! school_params
          old_teachers_count = Portal::Teacher.count
          old_schools_count = Portal::School.count
          post :create, teacher_and_new_school_params
          expect(response.status).to eq(201)
          expect(Portal::Teacher.count).to eq(old_teachers_count + 1)
          expect(Portal::School.count).to eq(old_schools_count)
        end
      end
    end
  end

  # TODO: auto-generated
  describe '#email_available' do
    it 'GET email_available' do
      get :email_available, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#login_available' do
    it 'GET login_available' do
      get :login_available, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  describe '#login_valid' do
    it 'GET login_valid' do
      get :login_valid, username: 'username'

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#name_valid' do
    it 'GET name_valid' do
      get :name_valid, name: 'name'

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#get_enews_subscription' do
    it 'GET get_enews_subscription' do
      sign_in teacher_user

      get :get_enews_subscription, id: FactoryBot.create(:portal_teacher).to_param

      expect(response).to have_http_status(:forbidden)
    end
  end

  # TODO: auto-generated
  describe '#update_enews_subscription' do
    it 'GET update_enews_subscription' do
      sign_in teacher_user

      get :update_enews_subscription, id: FactoryBot.create(:portal_teacher).to_param, status: 'subscribed'

      expect(response).to have_http_status(:forbidden)
    end
  end


end
