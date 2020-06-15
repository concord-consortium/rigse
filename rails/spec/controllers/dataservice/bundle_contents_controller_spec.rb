require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContentsController do
  
  def mock_bundle_content(stubs={})
    @mock_bundle_content ||= mock_model(Dataservice::BundleContent, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_bundle_contents as @dataservice_bundle_contents" do
      expect(Dataservice::BundleContent).to receive(:search).with(nil, nil, nil).and_return([mock_bundle_content])
      login_admin
      get :index
      expect(assigns[:dataservice_bundle_contents]).to eq([mock_bundle_content])
    end
  end

  describe "GET show" do
    it "assigns the requested bundle_content as @dataservice_bundle_content" do
      expect(Dataservice::BundleContent).to receive(:find).with("37").and_return(mock_bundle_content)
      login_admin
      get :show, :id => "37"
      expect(assigns[:dataservice_bundle_content]).to equal(mock_bundle_content)
    end
  end

  describe "GET new" do
    it "assigns a new bundle_content as @dataservice_bundle_content" do
      expect(Dataservice::BundleContent).to receive(:new).and_return(mock_bundle_content)
      login_admin
      get :new
      expect(assigns[:dataservice_bundle_content]).to equal(mock_bundle_content)
    end
  end

  describe "GET edit" do
    it "assigns the requested bundle_content as @dataservice_bundle_content" do
      expect(Dataservice::BundleContent).to receive(:find).with("37").and_return(mock_bundle_content)
      login_admin
      get :edit, :id => "37"
      expect(assigns[:dataservice_bundle_content]).to equal(mock_bundle_content)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created bundle_content as @dataservice_bundle_content" do
        expect(Dataservice::BundleContent).to receive(:new).with({'these' => 'params'}).and_return(mock_bundle_content(:save => true))
        login_admin
        post :create, :dataservice_bundle_content => {:these => 'params'}
        expect(assigns[:dataservice_bundle_content]).to equal(mock_bundle_content)
      end

      it "redirects to the created bundle_content" do
        expect(Dataservice::BundleContent).to receive(:new).and_return(mock_bundle_content(:save => true))
        login_admin
        post :create, :dataservice_bundle_content => {}
        expect(response).to redirect_to(dataservice_bundle_content_url(mock_bundle_content))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bundle_content as @dataservice_bundle_content" do
        expect(Dataservice::BundleContent).to receive(:new).with({'these' => 'params'}).and_return(mock_bundle_content(:save => false))
        login_admin
        post :create, :dataservice_bundle_content => {:these => 'params'}
        expect(assigns[:dataservice_bundle_content]).to equal(mock_bundle_content)
      end

      it "re-renders the 'new' template" do
        expect(Dataservice::BundleContent).to receive(:new).and_return(mock_bundle_content(:save => false))
        login_admin
        post :create, :dataservice_bundle_content => {}
        expect(response).to render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested bundle_content" do
        expect(Dataservice::BundleContent).to receive(:find).with("37").and_return(mock_bundle_content)
        login_admin
        expect(mock_bundle_content).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :dataservice_bundle_content => {:these => 'params'}
      end

      it "assigns the requested bundle_content as @dataservice_bundle_content" do
        expect(Dataservice::BundleContent).to receive(:find).and_return(mock_bundle_content(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        expect(assigns[:dataservice_bundle_content]).to equal(mock_bundle_content)
      end

      it "redirects to the bundle_content" do
        expect(Dataservice::BundleContent).to receive(:find).and_return(mock_bundle_content(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        expect(response).to redirect_to(dataservice_bundle_content_url(mock_bundle_content))
      end
    end

    describe "with invalid params" do
      it "updates the requested bundle_content" do
        expect(Dataservice::BundleContent).to receive(:find).with("37").and_return(mock_bundle_content)
        login_admin
        expect(mock_bundle_content).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :dataservice_bundle_content => {:these => 'params'}
      end

      it "assigns the bundle_content as @dataservice_bundle_content" do
        expect(Dataservice::BundleContent).to receive(:find).and_return(mock_bundle_content(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        expect(assigns[:dataservice_bundle_content]).to equal(mock_bundle_content)
      end

      it "re-renders the 'edit' template" do
        expect(Dataservice::BundleContent).to receive(:find).and_return(mock_bundle_content(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested bundle_content" do
      expect(Dataservice::BundleContent).to receive(:find).with("37").and_return(mock_bundle_content)
      login_admin
      expect(mock_bundle_content).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_bundle_contents list" do
      expect(Dataservice::BundleContent).to receive(:find).and_return(mock_bundle_content(:destroy => true))
      login_admin
      delete :destroy, :id => "1"
      expect(response).to redirect_to(dataservice_bundle_contents_url)
    end
  end

end
