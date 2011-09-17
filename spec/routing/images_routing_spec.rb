require File.expand_path('../../spec_helper', __FILE__)

describe  ImagesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "images" }.should route_to(:controller => "images", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "images/new" }.should route_to(:controller => "images", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "images/1" }.should route_to(:controller => "images", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "images/1/edit" }.should route_to(:controller => "images", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "images" }.should route_to(:controller => "images", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "images/1" }.should route_to(:controller => "images", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "images/1" }.should route_to(:controller => "images", :action => "destroy", :id => "1") 
    end
  end
end
