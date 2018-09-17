# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::Nces06DistrictsController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    before(:each) do
      @manager_user = FactoryBot.generate(:manager_user)
      allow(controller).to receive(:current_visitor).and_return(@manager_user)

      login_manager
    end

    it 'GET index' do
      get :index, {}, {}

      expect(response).to have_http_status(:ok)
    end

    it 'GET index for state' do
      get :index, state_or_province: 'WA'

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, id: 123

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

end
