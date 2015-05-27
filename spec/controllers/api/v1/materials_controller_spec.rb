# encoding: utf-8
require 'spec_helper'

describe API::V1::MaterialsController do
  describe 'GET featured' do
    before(:each) do
      FactoryGirl.create_list(:investigation, 2)
      FactoryGirl.create_list(:activity, 2)
      FactoryGirl.create_list(:external_activity, 2)
      Activity.first.update_attributes!(is_featured: true, publication_status: 'published')
      ExternalActivity.first.update_attributes!(is_featured: true, publication_status: 'published')
      Investigation.first.update_attributes!(is_featured: true, publication_status: 'published')
      Investigation.last.update_attributes!(is_featured: true) # not published, shouldn't be returned!
    end

    it 'should return list of featured activities' do
      get :featured
      expect(response.status).to eql(200)
      materials = JSON.parse(response.body)
      expect(materials.length).to eql(3)
    end

    describe 'prioritization' do
      it 'should respect prioritize priority_type parameters' do
        get :featured, {prioritize: Activity.first.id, priority_type: 'activity'}
        materials = JSON.parse(response.body)
        expect(materials[0]['id']).to eql(Activity.first.id)

        get :featured, {prioritize: ExternalActivity.first.id, priority_type: 'external_activity'}
        materials = JSON.parse(response.body)
        expect(materials[0]['id']).to eql(ExternalActivity.first.id)

        get :featured, {prioritize: Investigation.first.id, priority_type: 'investigation'}
        materials = JSON.parse(response.body)
        expect(materials[0]['id']).to eql(Investigation.first.id)
      end
    end
  end

  describe 'GET own' do
    let(:user) { FactoryGirl.create(:confirmed_user) }
    before(:each) do
      sign_in user
      @m1 = FactoryGirl.create(:external_activity, user: user)
      @m2 = FactoryGirl.create(:activity, user: user)
      @m3 = FactoryGirl.create(:investigation, user: user)
      # Materials defined below should NOT be listed:
      e1 = FactoryGirl.create(:external_activity)
      e2 = FactoryGirl.create(:external_activity)
      FactoryGirl.create(:activity, user: user, external_activities: [e1])      # template
      FactoryGirl.create(:investigation, user: user, external_activities: [e2]) # template
    end

    it 'should return own materials, but filter out all templates' do
      get :own
      expect(response.status).to eql(200)
      materials = JSON.parse(response.body)
      expect(materials.length).to eql(3)
      expect(materials[0]['id']).to eql(@m1.id)
      expect(materials[1]['id']).to eql(@m2.id)
      expect(materials[2]['id']).to eql(@m3.id)
    end
  end
end