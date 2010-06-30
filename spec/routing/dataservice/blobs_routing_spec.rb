require 'spec_helper'

describe Dataservice::BlobsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/dataservice_blobs" }.should route_to(:controller => "dataservice_blobs", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/dataservice_blobs/new" }.should route_to(:controller => "dataservice_blobs", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/dataservice_blobs/1" }.should route_to(:controller => "dataservice_blobs", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/dataservice_blobs/1/edit" }.should route_to(:controller => "dataservice_blobs", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/dataservice_blobs" }.should route_to(:controller => "dataservice_blobs", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/dataservice_blobs/1" }.should route_to(:controller => "dataservice_blobs", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/dataservice_blobs/1" }.should route_to(:controller => "dataservice_blobs", :action => "destroy", :id => "1") 
    end
  end
end
