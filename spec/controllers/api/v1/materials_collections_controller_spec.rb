# encoding: utf-8
require 'spec_helper'

describe API::V1::MaterialsCollectionsController do
  let(:collection) { FactoryGirl.create(:materials_collection) }
  let(:ext_act) { FactoryGirl.create_list(:external_activity, 3) }
  let(:act) { FactoryGirl.create_list(:activity, 3) }
  let(:inv) { FactoryGirl.create_list(:investigation, 3) }
  let(:materials) { ext_act + act + inv }

  before(:each) do
    # Assign some materials to cohorts.
    materials.each_with_index do |m, i|
      m.cohort_list = ["foo"] if i % 3 === 0
      m.cohort_list = ["bar"] if i % 3 === 1
      m.save!
    end
    # Assign all materials to collection.
    materials.each do |m|
      FactoryGirl.create(:materials_collection_item, material: m, materials_collection: collection)
    end
  end

  describe 'GET data' do
    context 'when user is not assigned to any cohorts' do
      it 'should return materials that are not assigned to any cohorts' do
        get :data, id: collection.id
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        expect(results.length).to eql(1)
        expect(results[0]['name']).to eql(collection.name)
        expect(results[0]['materials'].length).to eql(3)
      end
    end

    context 'when user is assigned to some cohorts' do
      let(:teacher) { Factory.create(:portal_teacher) }
      before(:each) do
        sign_in teacher.user
      end

      it 'should return materials that are in the same cohort or materials not assigned to any cohort' do
        teacher.cohort_list = ["foo"]
        teacher.save!

        get :data, id: collection.id
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        expect(results.length).to eql(1)
        expect(results[0]['name']).to eql(collection.name)
        expect(results[0]['materials'].length).to eql(6)
      end
    end
  end
end