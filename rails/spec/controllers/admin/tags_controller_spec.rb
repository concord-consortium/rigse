require 'spec_helper'

describe Admin::TagsController do

  let (:tag_params) {{
    "scope" => "test scope", "tag" => "test tag"
  }}

  before(:each) do
    login_admin
  end

  def mock_tags(stubs={})
    @mock_tags ||= mock_model(Admin::Tag, stubs)
  end

  describe "GET index" do
    it "assigns all admin_tags as @admin_tags" do
      allow(Admin::Tag).to receive(:search).with(nil, nil, nil).and_return([mock_tags])
      get :index
      expect(assigns[:admin_tags]).to eq([mock_tags])
    end
  end

  describe "GET show" do
    it "assigns the requested tags as @tags" do
      allow(Admin::Tag).to receive(:find).with("37").and_return(mock_tags)
      get :show, params: { :id => "37" }
      expect(assigns[:admin_tag]).to equal(mock_tags)
    end
  end

  describe "GET new" do
    it "assigns a new tags as @tags" do
      allow(Admin::Tag).to receive(:new).and_return(mock_tags)
      get :new
      expect(assigns[:admin_tag]).to equal(mock_tags)
    end
  end

  describe "GET edit" do
    it "assigns the requested tags as @tags" do
      allow(Admin::Tag).to receive(:find).with("37").and_return(mock_tags)
      get :edit, params: { :id => "37" }
      expect(assigns[:admin_tag]).to equal(mock_tags)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created tags as @tags" do
        allow(Admin::Tag).to receive(:new).with(permit_params!(tag_params)).and_return(mock_tags(:save => true))
        post :create, params: { :admin_tag => tag_params }
        expect(assigns[:admin_tag]).to equal(mock_tags)
      end

      it "redirects to the created tags" do
        allow(Admin::Tag).to receive(:new).and_return(mock_tags(:save => true))
        post :create, params: { :admin_tag => {} }
        expect(response).to redirect_to(admin_tag_url(mock_tags))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved tags as @tags" do
        allow(Admin::Tag).to receive(:new).with(permit_params!(tag_params)).and_return(mock_tags(:save => false))
        post :create, params: { :admin_tag => tag_params }
        expect(assigns[:admin_tag]).to equal(mock_tags)
      end

      it "re-renders the 'new' template" do
        allow(Admin::Tag).to receive(:new).and_return(mock_tags(:save => false))
        post :create, params: { :admin_tag => {} }
        expect(response).to render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested tags" do
        expect(Admin::Tag).to receive(:find).with("37").and_return(mock_tags)
        expect(mock_tags).to receive(:update).with(permit_params!(tag_params))
        put :update, params: { :id => "37", :admin_tag => tag_params }
      end

      it "assigns the requested tags as @tags" do
        allow(Admin::Tag).to receive(:find).and_return(mock_tags(:update => true))
        put :update, params: { :id => "1" }
        expect(assigns[:admin_tag]).to equal(mock_tags)
      end

      it "redirects to the tags" do
        allow(Admin::Tag).to receive(:find).and_return(mock_tags(:update => true))
        put :update, params: { :id => "1" }
        expect(response).to redirect_to(admin_tag_url(mock_tags))
      end
    end

    describe "with invalid params" do
      it "updates the requested tags" do
        expect(Admin::Tag).to receive(:find).with("37").and_return(mock_tags)
        expect(mock_tags).to receive(:update).with(permit_params!(tag_params))
        put :update, params: { :id => "37", :admin_tag => tag_params }
      end

      it "assigns the tags as @tags" do
        allow(Admin::Tag).to receive(:find).and_return(mock_tags(:update => false))
        put :update, params: { :id => "1" }
        expect(assigns[:admin_tag]).to equal(mock_tags)
      end

      it "re-renders the 'edit' template" do
        allow(Admin::Tag).to receive(:find).and_return(mock_tags(:update => false))
        put :update, params: { :id => "1" }
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested tags" do
      expect(Admin::Tag).to receive(:find).with("37")
        .and_return(mock_tags(name:'tag'))
      expect(mock_tags).to receive(:destroy)
      delete :destroy, params: { :id => "37" }
    end

    it "redirects to the admin_tags list" do
      allow(Admin::Tag).to receive(:find)
        .and_return(mock_tags(destroy: true, name:'tag'))
      delete :destroy, params: { :id => "1" }
      expect(response).to redirect_to(admin_tags_url)
    end
  end
end
