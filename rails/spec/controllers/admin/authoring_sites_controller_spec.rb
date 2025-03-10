# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::AuthoringSitesController, type: :controller do

  let(:data) {Admin::AuthoringSite}
  let(:params_key) { :admin_authoring_site }
  let(:valid_attributes)  { { } }
  let(:admin_user) {FactoryBot.generate(:admin_user)}
  let(:stubs) {{}}
  let(:mock_content) {
    mock_model data, stubs
  }
  let(:mock_content_id) do
    mock_content.id
  end

  before(:each) do
    warden.set_user(admin_user, scope: :user)
  end

  describe "GET new" do
    it "renders the new form" do
      get :new
      expect(response).to render_template("new")
      expect(response).to be_successful
    end
  end

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      expect(data).to receive(:find).and_return(mock_content)
      get :show, params: { id: mock_content_id }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      expect(data).to receive(:find).and_return(mock_content)
      get :edit, params: { id: mock_content_id }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    xit "creates a new <data>" do
      expect {
        post :create, params: { params_key => valid_attributes }
      }.to change(data, :count).by(1)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    let(:stubs) {{update: true}}
    it "updates the model, redirects to index" do
      expect(data).to receive(:find).and_return(mock_content)
      put :update, params: { :id => mock_content_id, params_key => {:params => 'params'} }
      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      expect(data).to receive(:find).and_return(mock_content)
      delete :destroy, params: { id: mock_content_id }

      expect(response).to have_http_status(:redirect)
    end
  end

end
