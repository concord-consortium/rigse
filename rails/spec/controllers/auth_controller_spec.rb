# frozen_string_literal: false

require 'spec_helper'

RSpec.describe AuthController, type: :controller do

  # TODO: auto-generated
  describe '#login' do
    it 'GET login' do
      get :login

      expect(response).to have_http_status(:ok)
    end
  end

  describe '#oauth_authorize' do
    let (:params) { {} }

    subject { get :oauth_authorize, params: params }

    context 'without a logged in user' do
      context 'with invalid parameters' do
        context 'when the validation raises an error' do
          before(:each) {
            expect(AccessGrant).to receive(:validate_oauth_authorize)
              .and_raise("Mock Error")
          }
          it 'raises an error' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end
        context 'when the validation has an error_redirect' do
          before(:each) {
            expect(AccessGrant).to receive(:validate_oauth_authorize)
              .and_return(AccessGrant::ValidationResult.new(false, nil, "http://error.redirect"))
          }
          it 'redirects to the error_redirect' do
            expect(subject).to redirect_to("http://error.redirect")
          end
        end
      end

      context 'with valid parameters' do
        let (:client) { FactoryBot.create(:client, name: 'Foo', app_id: 'test-client') }
        let (:params) { {client_id: client.app_id} }

        before(:each) {
          expect(AccessGrant).to receive(:validate_oauth_authorize)
            .and_return(AccessGrant::ValidationResult.new(true, client, nil))
        }

        it 'redirects' do
          expect(subject).to have_http_status(:redirect)
        end

        it 'redicts with an after_sign_in_path' do
          expect(subject.location).to include('after_sign_in_path')
        end

        it "redirects with the client's app name" do
          expect(subject.location).to include('app_name=Foo')
        end

      end

    end
  end

  # TODO: auto-generated
  describe '#access_token' do
    it 'GET access_token' do
      get :access_token

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#failure' do
    it 'GET failure' do
      get :failure

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#user' do
    it 'GET user' do
      get :user

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#isalive' do
    it 'GET isalive' do
      get :isalive

      expect(response).to have_http_status(:redirect)
    end
  end

end
