require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "dataservice/console_loggers" }.should route_to(:controller => "dataservice/console_loggers", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "dataservice/console_loggers/new" }.should route_to(:controller => "dataservice/console_loggers", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "dataservice/console_loggers/1" }.should route_to(:controller => "dataservice/console_loggers", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "dataservice/console_loggers/1/edit" }.should route_to(:controller => "dataservice/console_loggers", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "dataservice/console_loggers" }.should route_to(:controller => "dataservice/console_loggers", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "dataservice/console_loggers/1" }.should route_to(:controller => "dataservice/console_loggers", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "dataservice/console_loggers/1" }.should route_to(:controller => "dataservice/console_loggers", :action => "destroy", :id => "1") 
    end
  end
end
