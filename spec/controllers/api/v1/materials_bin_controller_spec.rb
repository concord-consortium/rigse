# encoding: utf-8
require 'spec_helper'

describe API::V1::MaterialsBinController do
  let(:foo_cohort) { FactoryGirl.create(:admin_cohort, name: 'foo') }
  let(:bar_cohort) { FactoryGirl.create(:admin_cohort, name: 'bar') }

  def sign_in_user_in_cohort(cohort)
    teacher = Factory.create(:portal_teacher)
    teacher.cohorts = [cohort]
    sign_in teacher.user
  end

  describe 'GET collections' do
    let(:collection) { FactoryGirl.create(:materials_collection) }
    let(:ext_act) { FactoryGirl.create_list(:external_activity, 9) }
    let(:materials) { ext_act }
    before(:each) do
      # Assign some materials to cohorts and mark the first one as assessment item.
      materials.each_with_index do |m, i|
        m.cohorts = [foo_cohort] if i % 3 === 0
        m.cohorts = [bar_cohort] if i % 3 === 1
        m.save!
      end
      # Set one material to be an assessment item.
      materials[2].update_attributes!(is_assessment_item: true)
      # Assign all materials to collection.
      materials.each do |m|
        FactoryGirl.create(:materials_collection_item, material: m, materials_collection: collection)
      end
    end

    context 'when user is an anonymous user not assigned to any cohorts' do
      it 'should return materials that are not assigned to any cohorts and are not marked as assessment items' do
        get :collections, id: collection.id
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        expect(results.length).to eql(1)
        expect(results[0]['name']).to eql(collection.name)
        # There are 3 materials without any cohort, but one of them is an assessment item.
        expect(results[0]['materials'].length).to eql(2)
      end
    end

    context 'when user is a teacher assigned to some cohorts' do
      before(:each) do
        sign_in_user_in_cohort(foo_cohort)
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

  let(:user1) { t = FactoryGirl.create(:teacher); t.user }
  let(:user2) { t = FactoryGirl.create(:teacher); t.user }
  let(:user3) { t = FactoryGirl.create(:teacher); t.user }
  let(:user4) { t = FactoryGirl.create(:teacher); t.user }
  let (:act1) { FactoryGirl.create(:external_activity, user: user1, publication_status: 'published') }
  let (:user2_public_activity) { FactoryGirl.create(:external_activity, user: user2, publication_status: 'published', is_assessment_item: true) }
  let (:user2_private_activity) { FactoryGirl.create(:external_activity, user: user2, publication_status: 'private') }
  # materials that might not be taken into account:
  let (:official_activity) { FactoryGirl.create(:external_activity, user: user3, is_official: true, publication_status: 'published') }
  let (:cohort_activity) { FactoryGirl.create(:external_activity, user: user3, publication_status: 'published') }
  let (:user3_private_activity) { FactoryGirl.create(:external_activity, user: user3, publication_status: 'private') }
  # investigation is considered to be always official
  let (:inv) { FactoryGirl.create(:investigation, user: user3, publication_status: 'published') }
  # user with an archived and private activity
  let (:user4_archived_activity) { FactoryGirl.create(:external_activity, user: user4, is_archived: true) }
  let (:user4_private_activity) { FactoryGirl.create(:external_activity, user: user4, publication_status: 'private') }
  let (:user4_public_activity) { FactoryGirl.create(:external_activity, user: user4, publication_status: 'published') }

  def populate_example_materials
    # Make sure that objects are saved to DB.
    cohort_activity.cohorts = [foo_cohort]
    act1; user2_public_activity; official_activity; cohort_activity; user2_private_activity; inv
    # the order matters here. in the code we are testing if the filters are applied
    # after the grouping then only the archived activity will be in the list and this user will not show up
    # if the code is working correctly then it will find user4_public_activity and the user will show up
    user4_archived_activity; user4_private_activity; user4_public_activity
  end

  describe 'GET unofficial_materials_authors' do
    before(:each) do
      populate_example_materials
    end
    context 'when user is anonymous and not assigned to any cohorts' do
      it 'lists all unofficial materials authors respecting cohorts and assessment items' do
        get :unofficial_materials_authors
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        # Only act1 and user4_public_activity is public, not assigned to any cohort and not an assessment item.
        expect(results.length).to eql(2)
        expect(results[0]['id']).to eql(user1.id)
        expect(results[0]['name']).to eql(user1.name)
        expect(results[1]['id']).to eql(user4.id)
        expect(results[1]['name']).to eql(user4.name)
      end
    end

    context 'when user is a teacher assigned to some cohorts' do
      before(:each) do
        sign_in_user_in_cohort(foo_cohort)
      end
      it 'lists all unofficial materials authors respecting cohorts' do
        get :unofficial_materials_authors
        expect(response.status).to eql(200)
        results = JSON.parse(response.body)
        expect(results.length).to eql(4)
        expect(results.select {|r| r['id'] == user1.id}.length).to eql(1)
        expect(results.select {|r| r['id'] == user2.id}.length).to eql(1)
        expect(results.select {|r| r['id'] == user3.id}.length).to eql(1)
        expect(results.select {|r| r['id'] == user4.id}.length).to eql(1)
      end
    end
  end

  describe 'GET unofficial_materials' do
    before(:each) do
      populate_example_materials
    end
    let (:request_user) { user1 }
    let (:results) {
      get :unofficial_materials, user_id: request_user.id
      raise "Non 200 response status: #{response.status}" if response.status != 200
      JSON.parse(response.body)
    }

    it 'lists unofficial materials' do
      expect(results.length).to eql(1)
      expect(results[0]['id']).to eql(act1.id)
    end

    context 'when a user is not logged in' do
      let (:request_user) { user2 }
      it 'does not list private materials or assessment items' do
        expect(results.length).to eql(0)
      end
    end

    context 'when a user is logged in' do
      before(:each) do
        sign_in user2
      end

      context 'and requests their own materials' do
        let (:request_user) { user2 }
        it 'list private materials' do
          expect(results.length).to eql(2)
          expect(results[0]['id']).to eql(user2_public_activity.id)
          expect(results[1]['id']).to eql(user2_private_activity.id)
        end
      end

      context 'and requests other user\'s materials' do
        let (:request_user) { user3 }
        it 'does not list private materials' do
          expect(results.length).to eql(0)
        end
      end
    end

    context 'when an admin is logged in' do
      before(:each) do
        sign_in Factory.next(:admin_user)
      end

      let (:request_user) { user2 }
      it 'list private materials' do
        expect(results.length).to eql(2)
        ids = results.map{|activity| activity['id']}
        expect(ids).to include(user2_public_activity.id)
        expect(ids).to include(user2_private_activity.id)
      end
    end

    context 'when user is not assigned to any cohorts' do
      let (:request_user) { user3 }
      it 'filters out materials assigned to cohorts' do
        expect(results.length).to eql(0)
      end
    end

    context 'when user is assigned to some cohorts' do
      before(:each) do
        sign_in_user_in_cohort(foo_cohort)
      end
      let (:request_user) { user3 }
      it 'lists unofficial materials respecting cohorts' do
        expect(results.length).to eql(1)
        expect(results[0]['id']).to eql(cohort_activity.id)
      end
    end
  end
end
