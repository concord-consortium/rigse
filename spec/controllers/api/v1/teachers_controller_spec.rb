# encoding: utf-8
require 'spec_helper'

RSpec.describe API::V1::TeachersController, type: :controller do
  let(:school) { FactoryBot.create(:portal_school) }

  let(:teacher_params) do
    {
      first_name: "teacher",
      last_name: "doe",
      login: "teacher_user",
      password: "testingxxy",
      email: "teacher@concord.org",
      email_subscribed: true,
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

      it "creates a new teacher by SSO" do
        user = FactoryBot.create(:confirmed_user)
        user_session_info  = sign_in user
        old_teachers_count = Portal::Teacher.count
        expect(EnewsSubscription).to receive(:set_status).and_return({subscribed: 'subscribed'})
        # need to add omniauthor_email to the session, but also need to
        # include the warden authentiction info that comes from sign_in
        # normally sign_in sets up the default session so it isn't necessary
        # to pass it through to the post or get call
        post :create, teacher_params, {
          'warden.user.user.key'=> user_session_info,
          'omniauth_email' => 'teacher@concord.org'}
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

  describe '#get_teacher_project_views' do
    before(:each) do
      @teacher = FactoryBot.create(:portal_teacher)
      @project1 = FactoryBot.create(:project, name: 'Test Project One')
      @project2 = FactoryBot.create(:project, name: 'Test Project Two')
      @teacher.add_recent_collection_page(@project1)
    end

    context 'when a signed in teacher accesses their own recent collections pages' do
      before(:each) do
        sign_in @teacher.user
      end

      it 'GET get_teacher_project_views' do
        get :get_teacher_project_views, :id => @teacher.id
        expect(response.body).to include(@project1.name)
      end
    end

    context 'when an anonymous user tries to access a teacher\'s recent collections pages' do
      it 'GET get_teacher_project_views' do
        get :get_teacher_project_views, :id => @teacher.id
        expect(response.body).to include('Not authorized')
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

  # TODO: auto-generated
  describe '#login_valid' do
    it 'GET login_valid' do
      get :login_valid, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#name_valid' do
    it 'GET name_valid' do
      get :name_valid, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#get_enews_subscription' do
    it 'GET get_enews_subscription' do
      get :get_enews_subscription, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#update_enews_subscription' do
    it 'GET update_enews_subscription' do
      get :update_enews_subscription, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end
end
