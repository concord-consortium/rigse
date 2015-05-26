# encoding: utf-8
require 'spec_helper'

describe API::V1::MaterialsBinController do
  def sign_in_user_in_foo_cohort
    teacher = Factory.create(:portal_teacher, cohort_list: ['foo'])
    sign_in teacher.user
  end

  describe 'GET collections' do
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

    context 'when user is not assigned to any cohorts' do
      it 'should return materials that are not assigned to any cohorts' do
        get :collections, id: collection.id
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        expect(results.length).to eql(1)
        expect(results[0]['name']).to eql(collection.name)
        expect(results[0]['materials'].length).to eql(3)
      end
    end

    context 'when user is assigned to some cohorts' do
      before(:each) do
        sign_in_user_in_foo_cohort
      end

      it 'should return materials that are in the same cohort or materials not assigned to any cohort' do
        get :collections, id: collection.id
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        expect(results.length).to eql(1)
        expect(results[0]['name']).to eql(collection.name)
        expect(results[0]['materials'].length).to eql(6)
      end
    end
  end

  describe 'GET unofficial_materials & unofficial_materials_authors' do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:user3) { FactoryGirl.create(:user) }
    let (:act1) { FactoryGirl.create(:external_activity, user: user1) }
    let (:act2) { FactoryGirl.create(:external_activity, user: user2) }
    # materials that might not be taken into account:
    let (:act3) { FactoryGirl.create(:external_activity, user: user3, is_official: true) }
    let (:act4) { FactoryGirl.create(:external_activity, user: user3, cohort_list: ['foo']) }
    let (:inv) { FactoryGirl.create(:investigation, user: user3) } # investigation is considered to be always official
    before(:each) do
      # Make sure that objects are saved to DB.
      act1; act2; act3; act4; inv
    end

    describe 'GET unofficial_materials_authors' do
      context 'when user is not assigned to any cohorts' do
        it 'lists all unofficial materials authors respecting cohorts' do
          get :unofficial_materials_authors
          expect(response.status).to eql(200)
          results = JSON.parse(response.body)
          expect(results.length).to eql(2)
          expect(results[0]['id']).to eql(user1.id)
          expect(results[0]['name']).to eql(user1.name)
          expect(results[1]['id']).to eql(user2.id)
          expect(results[1]['name']).to eql(user2.name)
        end
      end

      context 'when user is assigned to some cohorts' do
        before(:each) do
          sign_in_user_in_foo_cohort
        end
        it 'lists all unofficial materials authors respecting cohorts' do
          get :unofficial_materials_authors
          expect(response.status).to eql(200)
          results = JSON.parse(response.body)
          expect(results.length).to eql(3)
          expect(results[0]['id']).to eql(user1.id)
          expect(results[0]['name']).to eql(user1.name)
          expect(results[1]['id']).to eql(user2.id)
          expect(results[1]['name']).to eql(user2.name)
          expect(results[2]['id']).to eql(user3.id)
          expect(results[2]['name']).to eql(user3.name)
        end
      end
    end

    describe 'GET unofficial_materials' do
      it 'lists unofficial materials' do
        get :unofficial_materials, user_id: user1.id
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        expect(results.length).to eql(1)
        expect(results[0]['id']).to eql(act1.id)
      end

      context 'when user is not assigned to any cohorts' do
        it 'filters out materials assigned to cohorts' do
          get :unofficial_materials, user_id: user3.id
          expect(response.status).to eql(200)
          results = JSON.parse(response.body)
          expect(results.length).to eql(0)
        end
      end

      context 'when user is assigned to some cohorts' do
        before(:each) do
          sign_in_user_in_foo_cohort
        end
        it 'lists unofficial materials respecting cohorts' do
          get :unofficial_materials, user_id: user3.id
          expect(response.status).to eql(200)
          results = JSON.parse(response.body)
          expect(results.length).to eql(1)
          expect(results[0]['id']).to eql(act4.id)
        end
      end
    end
  end
end