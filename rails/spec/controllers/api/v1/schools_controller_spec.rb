# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::SchoolsController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create

      expect(response).to have_http_status(:bad_request)
    end
  end

end
