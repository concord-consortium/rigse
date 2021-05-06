# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::BucketLoggersController, type: :controller do

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, params: {id: 1}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#show_by_learner' do
    it 'GET show_by_learner' do
      get :show_by_learner, params: {id: 1}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#show_by_name' do
    it 'GET show_by_name' do
      get :show_by_name, params: {name: "test"}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#show_log_items_by_learner' do
    it 'GET show_log_items_by_learner' do
      get :show_log_items_by_learner, params: {id: 1}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#show_log_items_by_name' do
    it 'GET show_log_items_by_name' do
      get :show_log_items_by_name, params: {name: "test"}

      expect(response).to have_http_status(:redirect)
    end
  end

end
