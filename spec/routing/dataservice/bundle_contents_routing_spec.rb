require 'spec_helper'

describe Dataservice::BundleContentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "dataservice/bundle_contents" }.should route_to(:controller => "dataservice/bundle_contents", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "dataservice/bundle_contents/new" }.should route_to(:controller => "dataservice/bundle_contents", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "dataservice/bundle_contents/1" }.should route_to(:controller => "dataservice/bundle_contents", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "dataservice/bundle_contents/1/edit" }.should route_to(:controller => "dataservice/bundle_contents", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "dataservice/bundle_contents" }.should route_to(:controller => "dataservice/bundle_contents", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "dataservice/bundle_contents/1" }.should route_to(:controller => "dataservice/bundle_contents", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "dataservice/bundle_contents/1" }.should route_to(:controller => "dataservice/bundle_contents", :action => "destroy", :id => "1") 
    end
  end
end
