# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::BookmarksController, type: :controller do

  before do
    login_admin
  end

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#add' do
    it 'GET add' do
      get :add, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#visit' do
    it 'GET visit' do
      get :visit, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#delete' do
    it 'GET delete' do
      get :delete, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#sort' do
    it 'GET sort' do
      get :sort, ids: [1,2].to_json

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#visits' do
    it 'GET visits' do
      get :visits, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

end
