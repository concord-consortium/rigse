require 'spec_helper'

describe Dataservice::BlobsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/dataservice/blobs" }.should route_to(:controller => "dataservice/blobs", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/dataservice/blobs/new" }.should route_to(:controller => "dataservice/blobs", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/dataservice/blobs/1" }.should route_to(:controller => "dataservice/blobs", :action => "show", :id => "1")
    end
    
    it "recognizes and generates the raw #show with a valid token" do
      { :get => "/dataservice/blobs/1.blob/8ad04a50ba96463d80407cd119173b86"}.should route_to(:controller => "dataservice/blobs", :action => "show", :format => "blob", :id => "1", :token => "8ad04a50ba96463d80407cd119173b86")
    end

    it "recognizes and generates #edit" do
      { :get => "/dataservice/blobs/1/edit" }.should route_to(:controller => "dataservice/blobs", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/dataservice/blobs" }.should route_to(:controller => "dataservice/blobs", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/dataservice/blobs/1" }.should route_to(:controller => "dataservice/blobs", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/dataservice/blobs/1" }.should route_to(:controller => "dataservice/blobs", :action => "destroy", :id => "1") 
    end
  end
end
