# frozen_string_literal: false

require 'spec_helper'

RSpec.describe AuthController, type: :controller do

  # TODO: auto-generated
  describe '#verify_logged_in' do
    it 'GET verify_logged_in' do
      get :verify_logged_in, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#login' do
    it 'GET login' do
      get :login, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#oauth_authorize' do
    it 'GET oauth_authorize' do
      get :oauth_authorize, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#access_token' do
    it 'GET access_token' do
      get :access_token, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#failure' do
    it 'GET failure' do
      get :failure, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#user' do
    it 'GET user' do
      get :user, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#isalive' do
    it 'GET isalive' do
      get :isalive, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

end
