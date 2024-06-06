require 'spec_helper'

RSpec.describe API::V1::PermissionFormsController, type: :controller do
  describe '#index' do
    it 'GET index' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
