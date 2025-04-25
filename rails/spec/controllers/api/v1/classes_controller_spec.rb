require 'spec_helper'

describe API::V1::ClassesController do
  let(:cohort)          { FactoryBot.create(:admin_cohort) }
  let(:teacher)           { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)             { FactoryBot.create(:portal_clazz, name: 'test class', teachers: [teacher]) }
  let(:runnable_a)          { FactoryBot.create(:external_activity, name: 'Test Sequence') }
  let(:offering_a)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_a}) }
  let(:runnable_b)          { FactoryBot.create(:external_activity, name: 'Archived Test Sequence', is_archived: true) }
  let(:offering_b)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_b}) }
  let(:runnable_c)          { FactoryBot.create(:external_activity, name: 'Test Sequence 2') }
  let(:offering_c)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_c}) }
  let(:learner)              { FactoryBot.create(:full_portal_learner, { offering: offering_a }) }

  let(:other_teacher)       { FactoryBot.create(:portal_teacher) }
  let(:other_clazz)         { FactoryBot.create(:portal_clazz, name: 'other class', teachers: [other_teacher]) }

  let(:student_user)    { FactoryBot.create(:confirmed_user, :login => "authorized_student") }
  let(:student)         { FactoryBot.create(:portal_student, :user_id => student_user.id) }

  let(:project)         { FactoryBot.create(:project, cohorts: [cohort]) }
  let(:researcher_user) {
    researcher = FactoryBot.generate(:researcher_user)
    researcher.researcher_for_projects << project
    researcher
  }

  describe "GET #show" do
    before (:each) do
      # initialize the clazz
      clazz
      offering_a
      offering_b
      offering_c
    end

    describe "as a teacher" do
      before (:each) do
        learner
        clazz.reload
        sign_in teacher.user
      end

      it "returns a 200 code for a valid class with non-anonymized student info" do
        get :show, params: { id: clazz.id }
        expect(response.status).to eql(200)
        expect(JSON.parse(response.body)["students"].length).to eq 1
        expect(JSON.parse(response.body)["students"][0]["first_name"]).to eq learner.student.first_name
        expect(JSON.parse(response.body)["students"][0]["last_name"]).to eq learner.student.last_name
      end

      it "returns only non archived offerings" do
        get :show, params: { id: clazz.id }
        json = JSON.parse(response.body)
        expect(json['offerings'].size).to eq 2
        expect(json['offerings'][0]['id']).to eq offering_a.id
        expect(json['offerings'][1]['id']).to eq offering_c.id
      end
    end

    describe "as a researcher" do
      before (:each) do
        researcher_user
        project
        learner
        clazz.reload
        researcher_user.reload
        sign_in researcher_user
      end

      it "returns a 200 code for a valid class with anonymized student info" do
        get :show, params: { id: clazz.id }
        expect(response.status).to eql(200)
        expect(JSON.parse(response.body)["students"].length).to eq 1
        expect(JSON.parse(response.body)["students"][0]["first_name"]).to eq "Student"
        expect(JSON.parse(response.body)["students"][0]["last_name"]).to eq "#{learner.student.id}"
      end
    end
  end

  describe "#set_is_archived" do
    before :each do
      sign_in teacher.user
    end

    it "should fail when id is a class that the teacher doesn't own" do
      post :set_is_archived, params: { id: other_clazz.id }
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["message"]).to eq "Not authorized"
    end

    it "should succeed when the id is a class the teacher owns" do
      post :set_is_archived, params: { id: clazz.id, is_archived: false }
      clazz.reload
      expect(response).to have_http_status(:ok)
      expect(clazz.is_archived).to eq false

      post :set_is_archived, params: { id: clazz.id, is_archived: true }
      clazz.reload
      expect(response).to have_http_status(:ok)
      expect(clazz.is_archived).to eq true
    end
  end

  describe "POST #create" do
    describe "as a student" do
      before :each do
        sign_in student_user
      end

      it "should fail" do
        post :create
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["message"]).to eq "Not authorized"
      end
    end

    describe "as a teacher" do
      before :each do
        sign_in teacher.user
      end

      it "should fail when no name is provided" do
        post :create, params: { name: nil }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["message"]).to eq "Missing class name"
      end

      it "should fail when no class word is provided" do
        post :create, params: { name: "Test Class", class_word: nil }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["message"]).to eq "Missing class word"
      end

      it "should succeed when a name and class word are provided" do
        post :create, params: { name: "Test Class", class_word: "testword" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["id"]).to_not be_nil
        expect(JSON.parse(response.body)["class_word"]).to eq "testword"
        expect(Portal::Clazz.find(JSON.parse(response.body)["id"]).name).to eq "Test Class"
        expect(Portal::Clazz.find(JSON.parse(response.body)["id"]).class_word).to eq "testword"
      end

      it "should succeed when a name and a request for an auto-generated class word are provided" do
        post :create, params: { name: "Test Class", auto_generate_class_word: true }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["id"]).to_not be_nil
        expect(JSON.parse(response.body)["class_word"]).to_not be_nil
        expect(Portal::Clazz.find(JSON.parse(response.body)["id"]).name).to eq "Test Class"
        expect(Portal::Clazz.find(JSON.parse(response.body)["id"]).class_word).to match(/class_#{teacher.user.id}\d+/)
      end

      it "should succeed when a name and a request for an auto-generated class word are provided along with a prefix" do
        post :create, params: { name: "Test Class", auto_generate_class_word: true, class_word_prefix: "test" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["id"]).to_not be_nil
        expect(JSON.parse(response.body)["class_word"]).to_not be_nil
        expect(Portal::Clazz.find(JSON.parse(response.body)["id"]).name).to eq "Test Class"
        expect(Portal::Clazz.find(JSON.parse(response.body)["id"]).class_word).to match(/test_#{teacher.user.id}\d+/)
      end
    end
  end

  describe '#mine' do
    describe "as a student" do
      before :each do
        student.add_clazz(clazz)
        sign_in student_user
      end

      it "should succeed but not include the student list" do
        get :mine
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["classes"][0]["students"].length).to eq 0
      end
    end

    describe "as a teacher" do
      before :each do
        student.add_clazz(clazz)
        sign_in teacher.user
      end

      it "should succeed and include the student list" do
        get :mine
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["classes"][1]["students"].length).to eq 1
      end
    end
  end

  # TODO: auto-generated
  describe '#info' do
    it 'GET info' do
      get :info

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#log_links' do
    it 'GET log_links' do
      get :log_links, params: {id: 1}

      expect(response).to have_http_status(:bad_request)
    end
  end
end
