# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::FirebaseAppsController, type: :controller do

  let(:data) {FirebaseApp}
  let(:params_key) { :firebase_app }
  let(:valid_attributes)  {{
    name: "test_app",
    client_email: "bam@bing.boom",
    private_key: "-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDzAReCWkVgF2eOAMvRRr6i1XOqVO7kcwbczahVR48ZhhmStJaU
P7aZKL9L3bgvQvL9D8T9zFwYjyGiaY5czdob79Z/R+0yReID7Aix7vuFf8e7Hfxk
ltDnCh9jcMTKUMeS4rx8dbAG0XtXkD7ayxv5wfBfaDl5GvtY88eLKgCi9QIDAQAB
AoGBAJP9TjvsjeN/XWl1wqqo0uCH7fEF2Jb4Fm3SMXn+IoAA0wItSKbwRlvwHNAv
L0RZGXJUcDvAgTXTtUAb2L9b/j9lc1/KzZbPFdJDe/A2vqoet8y2Fu955LeS2cPB
0AcCZeTfxtj65wrabapI+gRb6vsHo49FPh4PG3F+NzJZnZrhAkEA/XDgxS/fa0yX
PlUWiGjdDNSclkvbohJcDhQDtAJqbKxeL/xzgobDl4mCylrhsclIPUmXoMjvd8TB
qjqm7f+pdwJBAPV1PGmCqaUwRzY0lXuEBz2fj1RNT7yh5qHT6eZmrFTpb+B/UxXz
gEd86P++bdlXD9CAQFv0ss7sFK90DW71MfMCQCyuU9IvyHHARQHGOny+EAqNCTYu
FYCTQAtzV9vKeTzDfq9zEGI4pA75PUezkgqn88ZqTQMZqa4xz/rU8E0RP60CQQCC
LD5xpj3ZwRTDBngQHSDJ6YjVqHqVCzeIsx3kdqcGERan9F5X0d9CClh26MLQ9H8K
kDmRiuAZJNKDigRlx9tJAkAdrkzo40+vsucH9OxOcR7KkUfufL1EWC4qcqH46oDX
gpZlAvdO9CFaBcBKsAcJnNDQBY2lhFsSeqYs78PoW7Zz
-----END RSA PRIVATE KEY-----"
  }}
  let(:invalid_attributes)  {{
    name: "",
    client_email: "",
    private_key: ""
  }}
  let(:admin_user) {FactoryBot.generate(:admin_user)}
  let(:stubs) {{}}
  let(:mock_content) {
    mock_model data, stubs
  }
  let(:mock_content_id) do
    mock_content.id
  end

  before(:each) do
    sign_in admin_user
  end

  describe "GET new" do
    it "renders the new form" do
      get :new
      expect(response).to render_template("new")
      expect(response).to be_success
    end
  end

  describe '#index' do
    it 'GET index' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#show' do
    it 'GET show' do
      expect(data).to receive(:find).and_return(mock_content)
      get :show, params: { id: mock_content_id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#edit' do
    it 'GET edit' do
      expect(data).to receive(:find).and_return(mock_content)
      get :edit, params: { id: mock_content_id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#create' do
    it "with invalid params its fails" do
      post :create, params: { firebase_app: invalid_attributes }
      expect(response).to render_template("new")
    end
    it "with valid params its creates a new model, redirects to index" do
      post :create, params: { firebase_app: valid_attributes }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#update' do
    let(:stubs) {{update_attributes: true}}
    it "updates the model, redirects to index" do
      expect(data).to receive(:find).and_return(mock_content)
      put :update, params: { :id => mock_content_id, params_key => {:params => 'params'} }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#destroy' do
    it 'DELETE destroy' do
      expect(data).to receive(:find).and_return(mock_content)
      delete :destroy, params: { id: mock_content_id }
      expect(response).to have_http_status(:redirect)
    end
  end

end
