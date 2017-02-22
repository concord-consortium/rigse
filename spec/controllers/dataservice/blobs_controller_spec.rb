require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BlobsController do

  before(:each) do
    login_admin
  end
  
  def mock_blob(stubs={:token => "8ad04a50ba96463d80407cd119173b86"})
    @mock_blob ||= mock_model(Dataservice::Blob, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_blobs as @dataservice_blobs" do
      skip
      # this tests the default controller, but now we're setting @dataservice_blobs to be a search collection
      # Dataservice::Blob.stub(:all).and_return([mock_blob])
      # get :index
      # assigns[:dataservice_blobs].should == [mock_blob]
    end
  end

  describe "GET show" do
    it "assigns the requested blob as @blob" do
      allow(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
      get :show, :id => "37"
      expect(assigns[:dataservice_blob]).to equal(mock_blob)
    end
  end

  describe "GET new" do
    it "assigns a new blob as @blob" do
      allow(Dataservice::Blob).to receive(:new).and_return(mock_blob)
      get :new
      expect(assigns[:dataservice_blob]).to equal(mock_blob)
    end
  end

  describe "GET edit" do
    it "assigns the requested blob as @blob" do
      allow(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
      get :edit, :id => "37"
      expect(assigns[:dataservice_blob]).to equal(mock_blob)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created blob as @blob" do
        allow(Dataservice::Blob).to receive(:new).with({'these' => 'params'}).and_return(mock_blob(:save => true))
        post :create, :blob => {:these => 'params'}
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "redirects to the created blob" do
        allow(Dataservice::Blob).to receive(:new).and_return(mock_blob(:save => true))
        post :create, :blob => {}
        expect(response).to redirect_to(dataservice_blob_url(mock_blob))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved blob as @blob" do
        allow(Dataservice::Blob).to receive(:new).with({'these' => 'params'}).and_return(mock_blob(:save => false))
        post :create, :blob => {:these => 'params'}
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "re-renders the 'new' template" do
        allow(Dataservice::Blob).to receive(:new).and_return(mock_blob(:save => false))
        post :create, :blob => {}
        expect(response).to render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested blob" do
        expect(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
        expect(mock_blob).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :blob => {:these => 'params'}
      end

      it "assigns the requested blob as @blob" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "redirects to the blob" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(dataservice_blob_url(mock_blob))
      end
    end

    describe "with invalid params" do
      it "updates the requested blob" do
        expect(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
        expect(mock_blob).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :blob => {:these => 'params'}
      end

      it "assigns the blob as @blob" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "re-renders the 'edit' template" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested blob" do
      expect(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
      expect(mock_blob).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_blobs list" do
      allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(dataservice_blobs_url)
    end
  end

end
