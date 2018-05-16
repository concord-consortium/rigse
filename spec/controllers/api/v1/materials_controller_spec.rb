# encoding: utf-8
require 'spec_helper'

describe API::V1::MaterialsController do
  describe 'GET featured' do
    before(:each) do
      activity_params = [
        {is_featured: true, publication_status: 'published'},
        {is_featured: true, publication_status: 'published'},
        {is_featured: true},
        {is_featured: false},
        {is_featured: true, publication_status: 'published'}
      ]
      activity_params.each { |p| FactoryGirl.create(:external_activity, p) }
    end

    it 'should return list of featured activities' do
      get :featured
      expect(response.status).to eql(200)
      materials = JSON.parse(response.body)
      expect(materials.length).to eql(3)
    end

    describe 'prioritization' do
      it 'should respect prioritize priority_type parameters' do

        get :featured, {prioritize: ExternalActivity.first.id, priority_type: 'external_activity'}
        materials = JSON.parse(response.body)
        expect(materials[0]['id']).to eql(ExternalActivity.first.id)

        get :featured, {prioritize: ExternalActivity.last.id, priority_type: 'external_activity'}
        materials = JSON.parse(response.body)
        expect(materials[0]['id']).to eql(ExternalActivity.last.id)
      end
    end
  end

  describe 'GET own' do
    let(:user) { FactoryGirl.create(:confirmed_user) }
    before(:each) do
      sign_in user
      @m1 = FactoryGirl.create(:external_activity, user: user)
      @m2 = FactoryGirl.create(:external_activity, user: user)
      @m3 = FactoryGirl.create(:external_activity, user: user)
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