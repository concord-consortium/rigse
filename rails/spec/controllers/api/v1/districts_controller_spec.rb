# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::DistrictsController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index, params: { state: 'WA' }

      expect(response).to have_http_status(:ok)
    end
  end

end
