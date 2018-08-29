# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::SessionsController, type: :controller do

  # TODO: auto-generated
  describe '#create' do
    xit 'POST create' do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      post :create, user: { login: 'login' }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      delete :destroy

      expect(response).to have_http_status(:unauthorized)
    end
  end

end
