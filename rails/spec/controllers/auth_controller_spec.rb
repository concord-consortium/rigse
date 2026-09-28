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

        it 'passes a switch user URL that goes through reauth' do
          get :oauth_authorize, params: params
          expect(assigns(:switch_user_url)).to include('/auth/reauth')
          expect(assigns(:switch_user_url)).not_to include('login_hint')
        end

        it 'passes the app name from the client_id' do
          get :oauth_authorize, params: params
          expect(assigns(:app_name)).to eq('Test App')
        end
      end
    end
  end

  describe '#reauth' do
    context 'with a logged in user' do
      let(:user) { FactoryBot.create(:confirmed_user) }
      let(:after_sign_in_path) { '/auth/oauth_authorize?client_id=test&redirect_uri=http%3A%2F%2Flocalhost%2Fredirect&response_type=token' }

      before(:each) { sign_in user }

      it 'signs out the current user and redirects to login' do
        post :reauth, params: { after_sign_in_path: after_sign_in_path }
        expect(response).to redirect_to(auth_login_path(after_sign_in_path: after_sign_in_path))
        expect(controller.current_user).to be_nil
      end
    end

    context 'without a logged in user' do
      it 'redirects to login with after_sign_in_path' do
        after_sign_in_path = '/auth/oauth_authorize?client_id=test'
        post :reauth, params: { after_sign_in_path: after_sign_in_path }
        expect(response).to redirect_to(auth_login_path(after_sign_in_path: after_sign_in_path))
      end
    end
  end

  # TODO: auto-generated
  describe '#access_token' do
    it 'POST access_token without a client' do
      post :access_token

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('error' => 'Could not find application')
    end

    context 'for a public client without scopes, using PKCE' do
      let(:client)    { FactoryBot.create(:client, app_id: 'spa', client_type: Client::PUBLIC, redirect_uris: 'https://spa.example.org/') }
      let(:user)      { FactoryBot.create(:confirmed_user) }
      let(:verifier)  { 'v' * 43 }
      let(:challenge) { Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false) }

      def redeem(grant)
        post :access_token, params: { client_id: 'spa', code: grant.code, code_verifier: verifier, redirect_uri: 'https://spa.example.org/' }
        JSON.parse(response.body)
      end

      it 'exchanges the code once for an opaque token that lives a week' do
        grant = AccessGrant.create!(client: client, user: user, issue_code: true, code_challenge: challenge, redirect_uri: 'https://spa.example.org/')
        code = grant.code
        body = redeem(grant)
        expect(body).to eq('access_token' => grant.access_token, 'token_type' => 'bearer', 'expires_in' => AccessGrant::ExpireTime.to_i)
        expect(response.headers['Cache-Control']).to include('no-store')
        expect(grant.reload.access_token_expires_at).to be_within(1.minute).of(AccessGrant::ExpireTime.from_now)
        grant.code = code
        expect(redeem(grant)).to eq('error' => 'invalid_grant')
      end

      it 'refuses a code issued without a challenge' do
        grant = AccessGrant.create!(client: client, user: user, issue_code: true, redirect_uri: 'https://spa.example.org/')
        expect(redeem(grant)).to eq('error' => 'invalid_grant')
      end
    end

    context 'for a confidential client' do
      let(:client) { FactoryBot.create(:client, app_id: 'lara', app_secret: 's3cret', client_type: Client::CONFIDENTIAL, redirect_uris: 'https://lara.example.org/cb') }
      let(:user)   { FactoryBot.create(:confirmed_user) }
      let(:grant)  { AccessGrant.create!(client: client, user: user, issue_code: true, redirect_uri: 'https://lara.example.org/cb') }

      def redeem(code)
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: code }
        JSON.parse(response.body)
      end

      it 'redeems a code once' do
        code = grant.code
        expect(redeem(code)['access_token']).to eq(grant.access_token)
        expect(grant.reload.access_token_expires_at).to be > Time.now
        expect(redeem(code)).to eq('error' => 'Could not authenticate access code')
      end

      it "verifies a confidential client's PKCE challenge when it sent one" do
        verifier = 'v' * 43
        grant.update!(code_challenge: Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false))
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: grant.code, code_verifier: 'w' * 43 }
        expect(JSON.parse(response.body)).to eq('error' => 'Could not authenticate access code')
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: grant.code, code_verifier: verifier,
                                      redirect_uri: 'https://lara.example.org/cb' }
        expect(JSON.parse(response.body)['access_token']).to eq(grant.access_token)
      end

      it 'refuses a redirect_uri other than the one the code was issued for' do
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: grant.code, redirect_uri: 'https://lara.example.org/other' }
        expect(JSON.parse(response.body)).to eq('error' => 'Could not authenticate access code')
        expect(grant.reload.code).to be_present
      end

      it 'accepts a missing redirect_uri for now, and logs the client' do
        expect(Rails.logger).to receive(:warn).with(/redeemed a code without redirect_uri/).at_least(:once)
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: grant.code }
        expect(JSON.parse(response.body)['access_token']).to eq(grant.access_token)
      end

      it 'issues a scoped token to a scoped confidential client that sends its secret, without PKCE' do
        client.update!(scopes: 'portal-api')
        scoped_grant = AccessGrant.create!(client: client, user: user, issue_code: true, scope: 'portal-api', redirect_uri: 'https://lara.example.org/cb')
        code = scoped_grant.code
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: code, redirect_uri: 'https://lara.example.org/cb' }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include('token_type' => 'Bearer', 'scope' => 'portal-api')
        expect(AccessGrant.exists?(scoped_grant.id)).to be false
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: code, redirect_uri: 'https://lara.example.org/cb' }
        expect(JSON.parse(response.body)).to eq('error' => 'invalid_grant')
      end

      it "refuses another client's code" do
        FactoryBot.create(:client, app_id: 'other', app_secret: 'x', client_type: Client::CONFIDENTIAL)
        post :access_token, params: { client_id: 'other', client_secret: 'x', code: grant.code }
        expect(JSON.parse(response.body)).to eq('error' => 'Could not authenticate access code')
        expect(grant.reload.code).to be_present
      end

      it 'refuses a missing redirect_uri for a code issued with a PKCE challenge' do
        verifier = 'v' * 43
        grant.update!(code_challenge: Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false))
        post :access_token, params: { client_id: 'lara', client_secret: 's3cret', code: grant.code, code_verifier: verifier }
        expect(JSON.parse(response.body)).to eq('error' => 'Could not authenticate access code')
      end

      it 'answers invalid_client for a scoped confidential client without its secret' do
        client.update!(scopes: 'class:researcher-read')
        post :access_token, params: { client_id: 'lara', code: grant.code }
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)).to eq('error' => 'invalid_client')
      end

      it 'refuses a code that expired unredeemed, and its token never authenticated' do
        code = grant.code
        expect(User.find_for_token_authentication(access_token: grant.access_token)).to be_nil
        grant.update_column(:created_at, (AccessGrant::CodeExpireTime + 1.second).ago)
        expect(redeem(code)).to eq('error' => 'Could not authenticate access code')
      end
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
