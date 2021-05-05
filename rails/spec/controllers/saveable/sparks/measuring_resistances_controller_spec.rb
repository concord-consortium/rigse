# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Saveable::Sparks::MeasuringResistancesController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    xit 'GET index' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, params: { id: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, params: { id: 1 }

      expect(response).to have_http_status(:not_found)
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
      put :update, params: { id: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, params: { id: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end

end
