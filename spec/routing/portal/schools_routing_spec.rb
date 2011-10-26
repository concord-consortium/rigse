require File.expand_path('../../../spec_helper', __FILE__)

describe  Portal::SchoolsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "portal/schools" }.should route_to(:controller => "portal/schools", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "portal/schools/new" }.should route_to(:controller => "portal/schools", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "portal/schools/1" }.should route_to(:controller => "portal/schools", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "portal/schools/1/edit" }.should route_to(:controller => "portal/schools", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "portal/schools" }.should route_to(:controller => "portal/schools", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "portal/schools/1" }.should route_to(:controller => "portal/schools", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "portal/schools/1" }.should route_to(:controller => "portal/schools", :action => "destroy", :id => "1") 
    end
  end
end
