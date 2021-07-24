# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Import::ImportsController, type: :controller do

  before(:each) do
    @admin_user = FactoryBot.generate(:admin_user)
    allow(controller).to receive(:current_visitor).and_return(@admin_user)

    login_admin

  end

  # TODO: auto-generated
  describe '#import_school_district_json' do
    it 'GET import_school_district_json' do
      login_anonymous

      get :import_school_district_json

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_user_json' do
    it 'GET import_user_json' do
      get :import_user_json

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_school_district_status' do
    it 'GET import_school_district_status' do
      get :import_school_district_status

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#import_user_status' do
    it 'GET import_user_status' do
      get :import_user_status

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#download' do
    it 'GET download' do
      request.headers["HTTP_REFERER"] = "https://foo.bar.com/some/path.html"
      Import::Import.new(:import_type => Import::Import::IMPORT_TYPE_USER, import_data: {}).save!

      get :download

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#import_activity_status' do
    it 'GET import_activity_status' do
      get :import_activity_status

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#import_activity' do
    it 'GET import_activity' do
      get :import_activity

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#import_activity_progress' do
    it 'GET import_activity_progress' do
      get :import_activity_progress, xhr: true
    end
  end

  # TODO: auto-generated
  describe '#activity_clear_job' do
    it 'GET activity_clear_job' do
      Import::Import.create!(user_id: @admin_user.id, import_type: Import::Import::IMPORT_TYPE_ACTIVITY)
      get :activity_clear_job, xhr: true

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#batch_import_status' do
    it 'GET batch_import_status' do
      get :batch_import_status

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#batch_import_data' do
    it 'GET batch_import_data' do
      Import::Import.new(:import_type => Import::Import::IMPORT_TYPE_BATCH_ACTIVITY, import_data: {}).save!
      get :batch_import_data, xhr: true

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#batch_import' do
    it 'GET batch_import' do
      get :batch_import

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#failed_batch_import' do
    it 'GET failed_batch_import' do
      Import::Import.new(:import_type => Import::Import::IMPORT_TYPE_BATCH_ACTIVITY, import_data: {}).save!
      get :failed_batch_import

      expect(response).to have_http_status(:ok)
    end
  end

end
