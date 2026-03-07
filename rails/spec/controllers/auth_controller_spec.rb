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

    context 'with a logged in user' do
      let(:user) { FactoryBot.create(:confirmed_user) }
      let(:client) { FactoryBot.create(:client, name: 'Test App', app_id: 'test-client', :redirect_uris => 'http://test.host/redirect') }

      before(:each) do
        sign_in user
        # Stub the redirect URI generation so oauth_authorize can proceed
        allow(AccessGrant).to receive(:get_authorize_redirect_uri)
          .and_return("http://test.host/redirect#access_token=test&token_type=bearer")
      end

      context 'without login_hint' do
        let(:params) { { client_id: client.app_id, redirect_uri: 'http://test.host/redirect', response_type: 'token' } }

        it 'redirects normally' do
          get :oauth_authorize, params: params
          expect(response).to have_http_status(:redirect)
        end
      end

      context 'with login_hint matching current user' do
        let(:params) { { client_id: client.app_id, redirect_uri: 'http://test.host/redirect', response_type: 'token', login_hint: user.id.to_s } }

        it 'redirects normally' do
          get :oauth_authorize, params: params
          expect(response).to have_http_status(:redirect)
          expect(response.location).to include('access_token')
        end
      end

      context 'with login_hint not matching current user' do
        let(:params) { { client_id: client.app_id, redirect_uri: 'http://test.host/redirect', response_type: 'token', login_hint: '99999' } }

        it 'renders the login_hint_mismatch page' do
          get :oauth_authorize, params: params
          expect(response).to have_http_status(:ok)
          expect(response).to render_template('auth/login_hint_mismatch')
        end

        it 'passes the current user name to the view' do
          get :oauth_authorize, params: params
          expect(assigns(:user_name)).to eq(user.name)
        end

        it 'passes a continue URL without login_hint' do
          get :oauth_authorize, params: params
          expect(assigns(:continue_url)).not_to include('login_hint')
          expect(assigns(:continue_url)).to include('client_id')
        end

        it 'passes a switch user URL without login_hint' do
          get :oauth_authorize, params: params
          expect(assigns(:switch_user_url)).not_to include('login_hint')
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
