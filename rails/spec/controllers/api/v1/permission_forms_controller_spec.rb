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
  end
end
