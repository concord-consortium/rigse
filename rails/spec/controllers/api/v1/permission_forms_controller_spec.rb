require 'spec_helper'

RSpec.describe API::V1::PermissionFormsController, type: :controller do
  describe '#index' do
    it 'GET index' do
      skip "Skipping this test for now"
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
