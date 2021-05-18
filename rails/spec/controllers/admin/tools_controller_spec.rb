# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::ToolsController, type: :controller do

  let(:params_key) { :tool }

  let(:admin_user) {FactoryBot.generate(:admin_user)}
  let(:stubs) {{}}
  let(:mock_content) {
    mock_model Tool, stubs
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
      expect(response).to be_successful
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
      expect(Tool).to receive(:find).and_return(mock_content)
      get :show, params: { id: mock_content_id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#edit' do
    it 'GET edit' do
      expect(Tool).to receive(:find).and_return(mock_content)
      get :edit, params: { id: mock_content_id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#create' do
    it "creates a new model, redirects to index" do
      post :create, params: { tool: {} }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#update' do
    let(:stubs) {{update: true}}
    it "updates the model, redirects to index" do
      expect(Tool).to receive(:find).and_return(mock_content)
      put :update, params: { :id => mock_content_id, params_key => {:params => 'params'} }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#destroy' do
    it 'DELETE destroy' do
      expect(Tool).to receive(:find).and_return(mock_content)
      delete :destroy, params: { id: mock_content_id }
      expect(response).to have_http_status(:redirect)
    end

    it "nullifies the tool_id of external activities" do
      tool = FactoryBot.create(:tool)
      external_activity = FactoryBot.create(:external_activity, tool: tool)

      expect(external_activity.tool_id).to_not be_nil

      tool.destroy
      external_activity.reload
      expect(external_activity.tool_id).to be_nil
    end
  end

end
