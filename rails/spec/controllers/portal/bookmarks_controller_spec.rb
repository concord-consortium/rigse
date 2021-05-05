# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::BookmarksController, type: :controller do

  describe "when logged in as admin" do
    before do
      login_admin
    end

    # TODO: auto-generated
    describe '#index' do
      it 'GET index' do
        get :index, params: { clazz_id: 1 }

        expect(response).to have_http_status(:not_found)
      end
    end

    # TODO: auto-generated
    describe '#visit' do
      it 'GET visit' do
        get :visit, params: { id: 1 }

        expect(response).to have_http_status(:not_found)
      end
    end

    # TODO: auto-generated
    describe '#visits' do
      it 'GET visits' do
        get :visits

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "when not logged in" do

    # TODO: auto-generated
    describe '#index' do
      it 'GET index' do
        get :index, params: { clazz_id: 1 }

        expect(response).to have_http_status(:not_found)
      end
    end

    # TODO: auto-generated
    describe '#visit' do
      it 'GET visit' do
        get :visit, params: { id: 1 }

        expect(response).to have_http_status(:not_found)
      end
    end

    # TODO: auto-generated
    describe '#visits' do
      it 'GET visits' do
        get :visits

        expect(response).to have_http_status(:redirect)
      end
    end
  end

end
