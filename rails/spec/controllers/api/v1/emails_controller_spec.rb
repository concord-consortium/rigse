require 'spec_helper'

RSpec.describe API::V1::EmailsController, type: :controller do
  let(:user) { FactoryBot.create(:confirmed_user, email: 'teacher@example.com') }

  before(:each) do
    generate_default_settings_with_mocks
    ActionMailer::Base.deliveries.clear
    # Default: simulate OIDC authentication
    sign_in user
    request.env['portal.auth_strategy'] = 'oidc_bearer_token'
    request.env['portal.auth_client'] = 'test-cloud-function'
  end

  describe 'POST #oidc_send' do
    let(:valid_params) { { subject: 'Test Subject', message: 'Test message body' } }

    context 'with valid OIDC auth and params' do
      it 'sends an email and returns success' do
        expect(Rails.logger).to receive(:info).with(/OidcEmail: sent.*teacher@example.com.*Test Subject.*test-cloud-function/)
        post :oidc_send, params: valid_params, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to be true
        expect(ActionMailer::Base.deliveries.last.to).to include('teacher@example.com')
      end
    end

    context 'without authentication' do
      before do
        logout_user
        request.env['portal.auth_strategy'] = nil
      end

      it 'returns 401' do
        post :oidc_send, params: valid_params, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with non-OIDC authentication (session/JWT)' do
      it 'returns 403 and does not send email' do
        request.env['portal.auth_strategy'] = 'api_jwt'
        post :oidc_send, params: valid_params, format: :json
        expect(response).to have_http_status(:forbidden)
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context 'with missing subject' do
      it 'returns 400' do
        post :oidc_send, params: { message: 'body' }, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with missing message' do
      it 'returns 400' do
        post :oidc_send, params: { subject: 'subj' }, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with non-string subject' do
      it 'returns 422' do
        post :oidc_send, params: { subject: ['an', 'array'], message: 'body' }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to match(/must be strings/)
      end
    end

    context 'when user has no email' do
      before do
        user.update_column(:email, '')
      end

      it 'returns 422' do
        post :oidc_send, params: valid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to match(/no email/)
      end
    end

    context 'when mailer raises an error' do
      before do
        allow(OidcMailer).to receive_message_chain(:send_message, :deliver_now)
          .and_raise(Net::SMTPServerBusy.new('too busy'))
      end

      it 'returns 502 with error details' do
        post :oidc_send, params: valid_params, format: :json
        expect(response).to have_http_status(502)
        expect(JSON.parse(response.body)['message']).to match(/Email delivery failed:.*too busy/)
      end
    end

    context 'subject with newlines' do
      it 'strips newlines from the subject' do
        post :oidc_send, params: { subject: "Line1\r\nLine2", message: 'body' }, format: :json
        expect(response).to have_http_status(:ok)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).not_to match(/[\r\n]/)
      end
    end
  end
end
