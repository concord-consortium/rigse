# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::BucketContentsMetalController, type: :controller do

  # TODO: auto-generated
  describe '#create' do
    xit 'POST create' do
      post :create, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#create_by_learner' do
    xit 'GET create_by_learner' do
      get :create_by_learner, id: FactoryBot.create(:full_portal_learner).to_param

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#create_by_name' do
    it 'GET create_by_name' do
      get :create_by_name, name: 'name'

      expect(response).to have_http_status(:created)
    end
  end

end
