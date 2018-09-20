# encoding: utf-8
require 'spec_helper'

describe API::V1::MaterialsController do
  let(:user) {FactoryBot.create(:confirmed_user)}

  describe '#featured' do
    before(:each) do
      activity_params = [
          {is_featured: true, publication_status: 'published'},
          {is_featured: true, publication_status: 'published'},
          {is_featured: true},
          {is_featured: false},
          {is_featured: true, publication_status: 'published'}
      ]
      activity_params.each {|p| FactoryBot.create(:external_activity, p)}
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

  describe '#own' do
    let(:user) {FactoryBot.create(:confirmed_user)}

    before(:each) do
      sign_in user
      @m1 = FactoryBot.create(:external_activity, user: user)
      @m2 = FactoryBot.create(:external_activity, user: user)
      @m3 = FactoryBot.create(:external_activity, user: user)
      # Materials defined below should NOT be listed:
      e1 = FactoryBot.create(:external_activity)
      e2 = FactoryBot.create(:external_activity)
      FactoryBot.create(:activity, user: user, external_activities: [e1]) # template
      FactoryBot.create(:investigation, user: user, external_activities: [e2]) # template
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


  describe 'other actions' do
    before(:each) do
      sign_in user
      @m1 = FactoryBot.create(:external_activity, user: user)
      @m2 = FactoryBot.create(:external_activity, user: user)
      @m3 = FactoryBot.create(:external_activity, user: user)
      # Materials defined below should NOT be listed:
      e1 = FactoryBot.create(:external_activity)
      e2 = FactoryBot.create(:external_activity)
      FactoryBot.create(:activity, user: user, external_activities: [e1]) # template
      FactoryBot.create(:investigation, user: user, external_activities: [e2]) # template
    end
    

    # TODO: auto-generated
    describe '#all' do
      it 'GET all' do
        get :all

        expect(response).to have_http_status(:ok)
      end
    end

    # TODO: auto-generated
    describe '#remove_favorite' do
      it 'GET remove_favorite' do
        get :remove_favorite, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end

    # TODO: auto-generated
    describe '#add_favorite' do
      it 'GET add_favorite' do
        get :add_favorite, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end

    # TODO: auto-generated
    describe '#get_favorites' do
      it 'GET get_favorites' do
        get :get_favorites, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end

    # TODO: auto-generated
    describe '#show' do
      it 'GET show' do
        get :show, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end

    # TODO: auto-generated
    describe '#assign_to_class' do
      it 'GET assign_to_class' do
        admin = FactoryBot.generate :admin_user
        sign_in admin
        get :assign_to_class,
            class_id: FactoryBot.create(:portal_clazz).to_param,
            assign: '1',
            material_type: 'ExternalActivity',
            material_id: @m1.id

        expect(response).to have_http_status(:ok)
      end
    end

    # TODO: auto-generated
    describe '#get_materials_standards' do
      it 'GET get_materials_standards' do
        get :get_materials_standards, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end

    # TODO: auto-generated
    describe '#add_materials_standard' do
      it 'GET add_materials_standard' do
        get :add_materials_standard, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end

    # TODO: auto-generated
    describe '#remove_materials_standard' do
      it 'GET remove_materials_standard' do
        get :remove_materials_standard, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end

    # TODO: auto-generated
    describe '#get_standard_statements' do
      xit 'GET get_standard_statements' do
        get :get_standard_statements, {}, {}

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

end
