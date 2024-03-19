require 'spec_helper'

describe API::V1::TeacherClassesController do
  let(:teacher)           { FactoryBot.create(:portal_teacher) }
  let(:student)           { FactoryBot.create(:full_portal_student) }
  let(:clazz)             { FactoryBot.create(:portal_clazz, name: 'test class', teachers: [teacher]) }
  let(:runnable_a)          { FactoryBot.create(:external_activity, name: 'Test Sequence') }
  let(:offering_a)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_a}) }
  let(:runnable_b)          { FactoryBot.create(:external_activity, name: 'Archived Test Sequence', is_archived: true) }
  let(:offering_b)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_b}) }
  let(:runnable_c)          { FactoryBot.create(:external_activity, name: 'Test Sequence 2') }
  let(:offering_c)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_c}) }

  let(:clazz2)             { FactoryBot.create(:portal_clazz, name: 'test class #2', teachers: [teacher]) }
  let(:clazz3)             { FactoryBot.create(:portal_clazz, name: 'test class #3', teachers: [teacher]) }

  let(:other_teacher)       { FactoryBot.create(:portal_teacher) }
  let(:other_clazz)         { FactoryBot.create(:portal_clazz, name: 'other class', teachers: [other_teacher]) }

  describe "GET #show" do
    before (:each) do
      # initialize the clazz
      clazz
      sign_in teacher.user
    end

    it "fails on an invalid class" do
      get :show, params: { id: 0 }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "The requested teacher class was not found"
    end

    it "returns a 200 code for a valid teacher class" do
      teacher_clazz = Portal::TeacherClazz.where(clazz_id: clazz.id, teacher_id: teacher.id).first
      get :show, params: { id: teacher_clazz.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]).to eq({
        "id" => teacher_clazz.id,
        "name" => teacher_clazz.name,
        "class_word" => teacher_clazz.clazz.class_word,
        "description" => teacher_clazz.description,
        "position" => teacher_clazz.position
      })
    end
  end

  describe "#sort #copy" do

    [:sort, :copy].each do |action|
      it "should fail as anonymous" do
        post action, params: {id: 1}
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["message"]).to eq "You must be logged in to use this endpoint"
      end

      it "should fail as a student" do
        sign_in student.user
        post action, params: {id: 1}
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["message"]).to eq "You must be logged in as a teacher to use this endpoint"
      end

    end
  end

  describe "#sort" do
    before :each do
      sign_in teacher.user
    end

    it "should fail when ids are missing" do
      post :sort
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "Missing ids parameter"
    end

    it "should fail when ids are invalid" do
      post :sort, params: { ids: [0] }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "Invalid class id: 0"
    end

    it "should fail when ids are to classes that the teacher doesn't own" do
      post :sort, params: { ids: [other_clazz.id] }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "You are not a teacher of class: #{other_clazz.id}"
    end

    it "should succeed" do
      post :sort, params: { ids: [clazz3.id, clazz.id, clazz2.id] }
      expect(response).to have_http_status(:ok)
      expect(Portal::TeacherClazz.where(clazz_id: clazz3.id, teacher_id: teacher.id).first.position).to eq 1
      expect(Portal::TeacherClazz.where(clazz_id: clazz.id, teacher_id: teacher.id).first.position).to eq 2
      expect(Portal::TeacherClazz.where(clazz_id: clazz2.id, teacher_id: teacher.id).first.position).to eq 3

      post :sort, params: { ids: [clazz2.id, clazz3.id, clazz.id] }
      expect(response).to have_http_status(:ok)
      expect(Portal::TeacherClazz.where(clazz_id: clazz2.id, teacher_id: teacher.id).first.position).to eq 1
      expect(Portal::TeacherClazz.where(clazz_id: clazz3.id, teacher_id: teacher.id).first.position).to eq 2
      expect(Portal::TeacherClazz.where(clazz_id: clazz.id, teacher_id: teacher.id).first.position).to eq 3
    end
  end

  describe "#copy" do
    before :each do
      clazz
      sign_in teacher.user
    end

    it "should fail when id is a class that the teacher doesn't own" do
      post :copy, params: { id: other_clazz.id }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "You are not a teacher of the requested class"
    end

    it "should fail when name is blank" do
      post :copy, params: { id: clazz.id, name: "", classWord: "copyofclazz", description: "test of copy" }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "Name can't be blank"
    end

    it "should fail when class word is blank" do
      post :copy, params: { id: clazz.id, name: "Copy of clazz for unit test", classWord: "", description: "test of copy" }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "Class word can't be blank"
    end

    it "should fail when class word is taken" do
      post :copy, params: { id: clazz.id, name: "Copy of clazz for unit test", classWord: clazz.class_word, description: "test of copy" }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "Class word has already been taken"
    end

    it "should succeed when fields are valid" do
      post :copy, params: { id: clazz.id, name: "Copy of clazz for unit test", classWord: "copyofclazz", description: "test of copy" }
      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)["data"]
      expect(data["id"]).not_to be_nil
      expect(data["name"]).to eq "Copy of clazz for unit test"
      expect(data["class_word"]).to eq "copyofclazz"
      expect(data["description"]).to eq "test of copy"
      expect(data["position"]).to eq Portal::TeacherClazz.where(teacher_id: teacher.id).count

      copy_teacher_clazz = Portal::TeacherClazz.find_by_id(data["id"])
      expect(copy_teacher_clazz.id).not_to be Portal::TeacherClazz.where(clazz_id: clazz.id, teacher_id: teacher.id).first

      copy_clazz = copy_teacher_clazz.clazz
      expect(copy_clazz.id).not_to be clazz.id

      # the remaining code was copied from the old portal_class controller #copy spec
      expect(copy_clazz).not_to be_nil

      expect(copy_clazz.class_word).to eq "copyofclazz"
      expect(copy_clazz.description).to eq "test of copy"

      expect(copy_clazz.teachers.length).to eq(clazz.teachers.length)
      clazz.teachers.each do |teacher|
        expect(copy_clazz.teachers.find_by_id(teacher.id)).not_to be_nil
      end

      expect(copy_clazz.offerings.length).to eq(clazz.offerings.length)
      clazz.offerings.each do |offering|
        expect(copy_clazz.offerings.find_by_runnable_id(offering.runnable_id)).not_to be_nil
      end

      expect(copy_clazz.students.length).to eq(0)
    end
  end
end
