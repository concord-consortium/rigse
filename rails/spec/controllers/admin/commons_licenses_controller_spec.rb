# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::CommonsLicensesController, type: :controller do

  let(:data) {CommonsLicense}
  let(:params_key) { :commons_license }
  let(:valid_attributes)  { { name: 'name', code: 'code'} }
  let(:admin_user) {FactoryBot.generate(:admin_user)}
  let(:stubs) {{}}
  let(:mock_content) {
    mock_model data, stubs
  }
  let(:mock_content_id) do
    mock_content.id
  end
  let(:mock_content_code) do
    mock_content.code
  end

  before(:each) do
    sign_in admin_user
    allow(mock_content).to receive(:code).and_return('code')
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
      get :show, params: {code: mock_content_code}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      expect(data).to receive(:find).and_return(mock_content)
      get :edit, params: {code: mock_content_code}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it "creates a new <data>" do
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
      put :update, params: {:code => mock_content_code, params_key => {:params => 'params'}}
      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      expect(data).to receive(:find).and_return(mock_content)
      delete :destroy, params: {code: mock_content_code}

      expect(response).to have_http_status(:redirect)
    end
  end

end
