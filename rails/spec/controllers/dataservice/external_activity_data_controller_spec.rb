# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::ExternalActivityDataController, type: :controller do

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#create_by_protocol_version' do
    it 'GET create_by_protocol_version' do
      get :create_by_protocol_version

      expect(response).to have_http_status(:not_found)
    end
  end

end
