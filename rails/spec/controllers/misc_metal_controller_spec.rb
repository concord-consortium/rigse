# frozen_string_literal: false

require 'spec_helper'

RSpec.describe MiscMetalController, type: :controller do

  # TODO: auto-generated
  describe '#time' do
    it 'GET time' do
      get :time

      expect(response).to have_http_status(:ok)
    end
  end

end
