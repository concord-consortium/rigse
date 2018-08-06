require 'spec_helper'

describe API::V1::ClassesController do
  let(:teacher)           { Factory.create(:portal_teacher) }
  let(:clazz)             { Factory.create(:portal_clazz, name: 'test class', teachers: [teacher]) }
  let(:runnable_a)          { Factory.create(:external_activity, name: 'Test Sequence') }
  let(:offering_a)          { Factory.create(:portal_offering, {clazz: clazz, runnable: runnable_a}) }
  let(:runnable_b)          { Factory.create(:external_activity, name: 'Archived Test Sequence', is_archived: true) }
  let(:offering_b)          { Factory.create(:portal_offering, {clazz: clazz, runnable: runnable_b}) }
  let(:runnable_c)          { Factory.create(:external_activity, name: 'Test Sequence 2') }
  let(:offering_c)          { Factory.create(:portal_offering, {clazz: clazz, runnable: runnable_c}) }

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
      get :show, id: clazz.id
      response.status.should eql(200)
    end

    it "returns only non archived offerings" do
      get :show, id: clazz.id
      json = JSON.parse(response.body)
      expect(json['offerings'].size).to eq 2
      expect(json['offerings'][0]['id']).to eq offering_a.id
      expect(json['offerings'][1]['id']).to eq offering_c.id
    end
  end
end