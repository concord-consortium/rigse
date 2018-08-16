require File.expand_path('../../spec_helper', __FILE__)

describe  ImagesController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "images" }).to route_to(:controller => "images", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "images/new" }).to route_to(:controller => "images", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "images/1" }).to route_to(:controller => "images", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "images/1/edit" }).to route_to(:controller => "images", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "images" }).to route_to(:controller => "images", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "images/1" }).to route_to(:controller => "images", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "images/1" }).to route_to(:controller => "images", :action => "destroy", :id => "1") 
    end
  end
end
