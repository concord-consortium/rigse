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
      pending
      # this tests the default controller, but now we're setting @dataservice_blobs to be a search collection
      # Dataservice::Blob.stub(:find).with(:all).and_return([mock_blob])
      # get :index
      # assigns[:dataservice_blobs].should == [mock_blob]
    end
  end

  describe "GET show" do
    it "assigns the requested blob as @blob" do
      Dataservice::Blob.stub(:find).with("37").and_return(mock_blob)
      get :show, :id => "37"
      assigns[:dataservice_blob].should equal(mock_blob)
    end
  end

  describe "GET new" do
    it "assigns a new blob as @blob" do
      Dataservice::Blob.stub(:new).and_return(mock_blob)
      get :new
      assigns[:dataservice_blob].should equal(mock_blob)
    end
  end

  describe "GET edit" do
    it "assigns the requested blob as @blob" do
      Dataservice::Blob.stub(:find).with("37").and_return(mock_blob)
      get :edit, :id => "37"
      assigns[:dataservice_blob].should equal(mock_blob)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created blob as @blob" do
        Dataservice::Blob.stub(:new).with({'these' => 'params'}).and_return(mock_blob(:save => true))
        post :create, :blob => {:these => 'params'}
        assigns[:dataservice_blob].should equal(mock_blob)
      end

      it "redirects to the created blob" do
        Dataservice::Blob.stub(:new).and_return(mock_blob(:save => true))
        post :create, :blob => {}
        response.should redirect_to(dataservice_blob_url(mock_blob))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved blob as @blob" do
        Dataservice::Blob.stub(:new).with({'these' => 'params'}).and_return(mock_blob(:save => false))
        post :create, :blob => {:these => 'params'}
        assigns[:dataservice_blob].should equal(mock_blob)
      end

      it "re-renders the 'new' template" do
        Dataservice::Blob.stub(:new).and_return(mock_blob(:save => false))
        post :create, :blob => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested blob" do
        Dataservice::Blob.should_receive(:find).with("37").and_return(mock_blob)
        mock_blob.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :blob => {:these => 'params'}
      end

      it "assigns the requested blob as @blob" do
        Dataservice::Blob.stub(:find).and_return(mock_blob(:update_attributes => true))
        put :update, :id => "1"
        assigns[:dataservice_blob].should equal(mock_blob)
      end

      it "redirects to the blob" do
        Dataservice::Blob.stub(:find).and_return(mock_blob(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(dataservice_blob_url(mock_blob))
      end
    end

    describe "with invalid params" do
      it "updates the requested blob" do
        Dataservice::Blob.should_receive(:find).with("37").and_return(mock_blob)
        mock_blob.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :blob => {:these => 'params'}
      end

      it "assigns the blob as @blob" do
        Dataservice::Blob.stub(:find).and_return(mock_blob(:update_attributes => false))
        put :update, :id => "1"
        assigns[:dataservice_blob].should equal(mock_blob)
      end

      it "re-renders the 'edit' template" do
        Dataservice::Blob.stub(:find).and_return(mock_blob(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested blob" do
      Dataservice::Blob.should_receive(:find).with("37").and_return(mock_blob)
      mock_blob.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_blobs list" do
      Dataservice::Blob.stub(:find).and_return(mock_blob(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(dataservice_blobs_url)
    end
  end

end
