require 'spec_helper'

RSpec.describe API::V1::PermissionFormsController, type: :controller do
  let(:admin) { FactoryBot.generate(:admin_user) }

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

  it 'POST create creates a new permission form' do
    post :create, params: { permission_form: { name: 'Test Form', url: 'http://example.com', project_id: 1 } }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Test Form')
    expect(Portal::PermissionForm.first.name).to eq('Test Form')
  end

  it 'PUT update updates the permission form' do
    permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: 1)
    put :update, params: { id: permission_form.id, permission_form: { name: 'New Name' } }
    expect(response).to have_http_status(:ok)
    expect(Portal::PermissionForm.find(permission_form.id).name).to eq('New Name')
  end

  it 'DELETE destroy deletes the permission form' do
    permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: 1)
    expect(Portal::PermissionForm.count).to eq(1)
    delete :destroy, params: { id: permission_form.id }
    expect(response).to have_http_status(:ok)
    expect(Portal::PermissionForm.count).to eq(0)
  end
end
