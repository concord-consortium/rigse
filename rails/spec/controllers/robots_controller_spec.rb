# frozen_string_literal: false

require 'spec_helper'

RSpec.describe RobotsController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#sitemap' do
    it 'GET sitemap' do
      get :sitemap, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

end
