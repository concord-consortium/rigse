# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::BucketContentsMetalController, type: :request do

  # TODO: auto-generated
  describe '#create' do
    xit 'POST create' do
      # when converting from xit to it change these to url paths - too lazy to do it now :)
      post :create, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#create_by_learner' do
    xit 'GET create_by_learner' do
      # when converting from xit to it change these to url paths - too lazy to do it now :)
      get :create_by_learner, id: FactoryBot.create(:full_portal_learner).to_param

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#create_by_name' do
    it 'GET create_by_name' do
      post "/dataservice/bucket_loggers/name/name/bucket_contents.bundle"

      expect(response).to have_http_status(:created)
    end
  end

end
