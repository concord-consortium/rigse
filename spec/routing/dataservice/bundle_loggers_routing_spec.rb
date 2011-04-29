require 'spec_helper'

describe Dataservice::BundleContentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "dataservice/bundle_loggers" }.should route_to(:controller => "dataservice/bundle_loggers", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "dataservice/bundle_loggers/new" }.should route_to(:controller => "dataservice/bundle_loggers", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "dataservice/bundle_loggers/1" }.should route_to(:controller => "dataservice/bundle_loggers", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "dataservice/bundle_loggers/1/edit" }.should route_to(:controller => "dataservice/bundle_loggers", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "dataservice/bundle_loggers" }.should route_to(:controller => "dataservice/bundle_loggers", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "dataservice/bundle_loggers/1" }.should route_to(:controller => "dataservice/bundle_loggers", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "dataservice/bundle_loggers/1" }.should route_to(:controller => "dataservice/bundle_loggers", :action => "destroy", :id => "1") 
    end
  end
end
