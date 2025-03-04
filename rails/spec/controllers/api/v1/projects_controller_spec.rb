# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::ProjectsController, type: :controller do

  describe '#show' do
    before(:each) do
      @teacher = FactoryBot.create(:portal_teacher)
      @project1 = FactoryBot.create(:project, name: 'Test Project One', landing_page_slug: 'test-project-1')
    end

    context 'when an anonymous user tries to access a project' do
      it 'returns a 403 forbidden status' do
        get :show, params: { id: @project1.id }

        expect(response).to have_http_status(403)
      end
    end

    context 'when a signed in teacher accesses a project' do
      before(:each) do
        sign_in @teacher.user
      end

      it 'returns a 200 OK status for a valid project ID' do
        get :show, params: { id: @project1.id }

        expect(response).to have_http_status(:ok)
      end

      it 'returns a 404 page not found error for an invalid ID' do
        get :show, params: { id: 14159265359 }

        expect(response).to have_http_status(404)
      end
    end
  end



  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

end
