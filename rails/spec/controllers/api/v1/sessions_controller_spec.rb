# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::SessionsController, type: :controller do

  # TODO: auto-generated
  describe '#create' do
    xit 'POST create' do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      post :create, params: { user: { login: 'login' } }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    let(:admin_user) {FactoryBot.generate(:admin_user)}

    it 'DELETE destroy' do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      # devise requires a signed in user to sign out.  If there is no user the controller method is not invoked.
      sign_in admin_user
      delete :destroy

      expect(response).to have_http_status(:ok)
    end
  end

end
