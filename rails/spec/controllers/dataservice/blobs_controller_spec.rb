require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BlobsController do

  let (:blob_params) {{
    "checksum" => "12345", "content" => "test blob",
    "file_extension" => "txt", "learner_id" => "2", "mimetype" => "text/plain",
    "token" => "test-token"
  }}

  before(:each) do
    login_admin
  end

  def mock_blob(stubs={:token => "8ad04a50ba96463d80407cd119173b86"})
    @mock_blob ||= mock_model(Dataservice::Blob, stubs)
  end

  describe "GET show" do
    it "assigns the requested blob as @blob" do
      allow(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
      get :show, params: { :id => "37" }
      expect(assigns[:dataservice_blob]).to equal(mock_blob)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created blob as @blob" do
        allow(Dataservice::Blob).to receive(:new).with(permit_params!(blob_params)).and_return(mock_blob(:save => true))
        post :create, params: { :blob => blob_params }
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "redirects to the created blob" do
        allow(Dataservice::Blob).to receive(:new).and_return(mock_blob(:save => true))
        post :create, params: { :blob => {} }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved blob as @blob" do
        allow(Dataservice::Blob).to receive(:new).with(permit_params!(blob_params)).and_return(mock_blob(:save => false))
        post :create, params: { blob: blob_params }
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "re-renders the 'new' template" do
        allow(Dataservice::Blob).to receive(:new).and_return(mock_blob(:save => false))
        post :create, params: { blob: {} }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested blob" do
        expect(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
        expect(mock_blob).to receive(:update).with(permit_params!(blob_params))
        put :update, params: { :id => "37", :blob => blob_params }
      end

      it "assigns the requested blob as @blob" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update => true))
        put :update, params: { :id => "1" }
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "redirects to the blob" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update => true))
        put :update, params: { :id => "1" }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "with invalid params" do
      it "updates the requested blob" do
        expect(Dataservice::Blob).to receive(:find).with("37").and_return(mock_blob)
        expect(mock_blob).to receive(:update).with(permit_params!(blob_params))
        put :update, params: { :id => "37", :blob => blob_params }
      end

      it "assigns the blob as @blob" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update => false))
        put :update, params: { :id => "1" }
        expect(assigns[:dataservice_blob]).to equal(mock_blob)
      end

      it "re-renders the 'edit' template" do
        allow(Dataservice::Blob).to receive(:find).and_return(mock_blob(:update => false))
        put :update, params: { :id => "1" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

end
