# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::CoursesController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    xit 'GET show' do
      get :show, params: { id: FactoryBot.create(:course).to_param }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    xit 'GET edit' do
      get :edit, params: { id: FactoryBot.create(:course).to_param }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, {id: 1}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    xit 'DELETE destroy' do
      delete :destroy, params: { id: FactoryBot.create(:course).to_param }

      expect(response).to have_http_status(:ok)
    end
  end

end
