# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Import::ImportsController, type: :controller do

  # TODO: auto-generated
  describe '#import_school_district_json' do
    it 'GET import_school_district_json' do
      get :import_school_district_json, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_user_json' do
    it 'GET import_user_json' do
      get :import_user_json, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_school_district_status' do
    it 'GET import_school_district_status' do
      get :import_school_district_status, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_user_status' do
    it 'GET import_user_status' do
      get :import_user_status, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#download' do
    it 'GET download' do
      get :download, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_activity_status' do
    it 'GET import_activity_status' do
      get :import_activity_status, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_activity' do
    it 'GET import_activity' do
      get :import_activity, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_activity_progress' do
    it 'GET import_activity_progress' do
      get :import_activity_progress, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#activity_clear_job' do
    it 'GET activity_clear_job' do
      get :activity_clear_job, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#batch_import_status' do
    it 'GET batch_import_status' do
      get :batch_import_status, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#batch_import_data' do
    it 'GET batch_import_data' do
      get :batch_import_data, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#batch_import' do
    it 'GET batch_import' do
      get :batch_import, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#failed_batch_import' do
    it 'GET failed_batch_import' do
      get :failed_batch_import, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

end
