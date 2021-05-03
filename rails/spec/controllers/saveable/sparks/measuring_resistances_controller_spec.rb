# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Saveable::Sparks::MeasuringResistancesController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    xit 'GET index' do
      get :index, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, {id: 1}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, {id: 1}, {}

      expect(response).to have_http_status(:not_found)
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
      put :update, {id: 1}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, {id: 1}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

end
