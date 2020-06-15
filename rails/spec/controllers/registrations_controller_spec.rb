# frozen_string_literal: false

require 'spec_helper'

RSpec.describe RegistrationsController, type: :controller do

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      post :create, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end
end
