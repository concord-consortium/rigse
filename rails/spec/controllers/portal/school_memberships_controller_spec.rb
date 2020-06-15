# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::SchoolMembershipsController, type: :controller do

  before do
    login_admin
  end

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    xit 'GET show' do
      get :show, id: FactoryBot.create(:school_membership).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    xit 'GET edit' do
      get :edit, FactoryBot.create(:school_membership).to_param

      expect(response).to have_http_status(:ok)
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
    xit 'DELETE destroy' do
      delete :destroy, FactoryBot.create(:school_membership).to_param

      expect(response).to have_http_status(:ok)
    end
  end

end
