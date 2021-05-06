# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::ExternalActivityDataController, type: :controller do

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create, params: {id_or_key: 1}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#create_by_protocol_version' do
    it 'GET create_by_protocol_version' do
      post :create_by_protocol_version, params: {id_or_key: 1, version: 1}

      expect(response).to have_http_status(:not_found)
    end
  end

end
