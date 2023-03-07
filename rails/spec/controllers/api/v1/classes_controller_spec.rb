require 'spec_helper'

describe API::V1::ClassesController do
  let(:teacher)           { FactoryBot.create(:portal_teacher) }
  let(:clazz)             { FactoryBot.create(:portal_clazz, name: 'test class', teachers: [teacher]) }
  let(:runnable_a)          { FactoryBot.create(:external_activity, name: 'Test Sequence') }
  let(:offering_a)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_a}) }
  let(:runnable_b)          { FactoryBot.create(:external_activity, name: 'Archived Test Sequence', is_archived: true) }
  let(:offering_b)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_b}) }
  let(:runnable_c)          { FactoryBot.create(:external_activity, name: 'Test Sequence 2') }
  let(:offering_c)          { FactoryBot.create(:portal_offering, {clazz: clazz, runnable: runnable_c}) }

  let(:other_teacher)       { FactoryBot.create(:portal_teacher) }
  let(:other_clazz)         { FactoryBot.create(:portal_clazz, name: 'other class', teachers: [other_teacher]) }

  describe "GET #show" do
    before (:each) do
      # initialize the clazz
      clazz
      offering_a
      offering_b
      offering_c
      sign_in teacher.user
    end

    it "returns a 200 code for a valid class" do
      get :show, params: { id: clazz.id }
      expect(response.status).to eql(200)
    end

    it "returns only non archived offerings" do
      get :show, params: { id: clazz.id }
      json = JSON.parse(response.body)
      expect(json['offerings'].size).to eq 2
      expect(json['offerings'][0]['id']).to eq offering_a.id
      expect(json['offerings'][1]['id']).to eq offering_c.id
    end
  end

  describe "#set_is_archived" do
    before :each do
      sign_in teacher.user
    end

    it "should fail when id is a class that the teacher doesn't own" do
      post :set_is_archived, params: { id: other_clazz.id }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq "You are not a teacher of the requested class"
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

  # TODO: auto-generated
  describe '#mine' do
    it 'GET mine' do
      get :mine

      expect(response).to have_http_status(:bad_request)
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
