require File.expand_path('../../../spec_helper', __FILE__)

describe  Portal::SchoolsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "portal/schools" }).to route_to(:controller => "portal/schools", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "portal/schools/new" }).to route_to(:controller => "portal/schools", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "portal/schools/1" }).to route_to(:controller => "portal/schools", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "portal/schools/1/edit" }).to route_to(:controller => "portal/schools", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "portal/schools" }).to route_to(:controller => "portal/schools", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "portal/schools/1" }).to route_to(:controller => "portal/schools", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "portal/schools/1" }).to route_to(:controller => "portal/schools", :action => "destroy", :id => "1") 
    end
  end
end
