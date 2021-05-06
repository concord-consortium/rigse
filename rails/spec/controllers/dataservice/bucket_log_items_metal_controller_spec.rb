# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::BucketLogItemsMetalController, type: :request do

  # TODO: auto-generated
  describe '#create' do
    xit 'POST create' do
      post "/dataservice/bucket_loggers/0/bucket_log_items.bundle"
      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#create_by_learner' do
    it 'GET create_by_learner' do
      post "/dataservice/bucket_loggers/learner/0/bucket_log_items.bundle", params: {}
      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#create_by_name' do
    it 'GET create_by_name' do
      post "/dataservice/bucket_loggers/name/name/bucket_log_items.bundle", params: {}
      expect(response).to have_http_status(:created)
    end
  end

end
