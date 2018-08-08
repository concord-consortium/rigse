require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "dataservice/console_contents" }).to route_to(:controller => "dataservice/console_contents", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "dataservice/console_contents/new" }).to route_to(:controller => "dataservice/console_contents", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "dataservice/console_contents/1" }).to route_to(:controller => "dataservice/console_contents", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "dataservice/console_contents/1/edit" }).to route_to(:controller => "dataservice/console_contents", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "dataservice/console_contents" }).to route_to(:controller => "dataservice/console_contents", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "dataservice/console_contents/1" }).to route_to(:controller => "dataservice/console_contents", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "dataservice/console_contents/1" }).to route_to(:controller => "dataservice/console_contents", :action => "destroy", :id => "1") 
    end
  end
end
