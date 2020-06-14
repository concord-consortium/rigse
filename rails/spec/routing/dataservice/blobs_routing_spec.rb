require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BlobsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "/dataservice/blobs" }).to route_to(:controller => "dataservice/blobs", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/dataservice/blobs/new" }).to route_to(:controller => "dataservice/blobs", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/dataservice/blobs/1" }).to route_to(:controller => "dataservice/blobs", :action => "show", :id => "1")
    end
    
    it "recognizes and generates the raw #show with a valid token" do
      expect({ :get => "/dataservice/blobs/1.blob/8ad04a50ba96463d80407cd119173b86"}).to route_to(:controller => "dataservice/blobs", :action => "show", :format => "blob", :id => "1", :token => "8ad04a50ba96463d80407cd119173b86")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/dataservice/blobs/1/edit" }).to route_to(:controller => "dataservice/blobs", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/dataservice/blobs" }).to route_to(:controller => "dataservice/blobs", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "/dataservice/blobs/1" }).to route_to(:controller => "dataservice/blobs", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/dataservice/blobs/1" }).to route_to(:controller => "dataservice/blobs", :action => "destroy", :id => "1") 
    end
  end
end
