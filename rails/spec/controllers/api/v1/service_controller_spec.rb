# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::ServiceController, type: :controller do

  # TODO: auto-generated
  describe '#solr_initialized' do
    it 'GET solr_initialized' do
      get :solr_initialized, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

end
