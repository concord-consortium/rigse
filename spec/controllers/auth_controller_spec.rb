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

  describe '#oauth_authorize' do
    let (:params) { {} }

    subject { get :oauth_authorize, params, {} }

    context 'without a logged in user' do
      it 'redirects' do
        expect(subject).to have_http_status(:redirect)
      end

      it 'redicts with an after_sign_in_path' do
        expect(subject.location).to include('after_sign_in_path')
      end

      # FIXME: this should actually return an error because we want to validate
      # the client paramters before redirecting
      context 'when a client_id is not passed' do
        it 'redirects without a app_name' do
          expect(subject.location).not_to include('app_name')
        end
      end

      context 'when a client_id param is passed' do
        let (:client) { FactoryBot.create(:client, name: 'Foo', app_id: 'test-client') }
        let (:params) { {client_id: client.app_id} }

        it "redirects with the client's app name" do
          expect(subject.location).to include('app_name=Foo')
        end
      end
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
