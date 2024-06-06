require 'spec_helper'

RSpec.describe API::V1::PermissionFormsController, type: :controller do
  let(:admin)         { FactoryBot.generate(:admin_user) }

  before do
    sign_in admin
  end

  describe 'get an ok response from the index endpoint' do
    it 'GET index' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns a list of permission forms including the created one' do
      Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: 1)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match([
        hash_including('name' => 'Test Form', 'url' => 'http://example.com', 'project_id' => 1)
      ])
    end
  end
end
