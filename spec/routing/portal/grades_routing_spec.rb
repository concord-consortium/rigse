require File.expand_path('../../../spec_helper', __FILE__)

describe  Portal::GradesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "portal/grades" }.should route_to(:controller => "portal/grades", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "portal/grades/new" }.should route_to(:controller => "portal/grades", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "portal/grades/1" }.should route_to(:controller => "portal/grades", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "portal/grades/1/edit" }.should route_to(:controller => "portal/grades", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "portal/grades" }.should route_to(:controller => "portal/grades", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "portal/grades/1" }.should route_to(:controller => "portal/grades", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "portal/grades/1" }.should route_to(:controller => "portal/grades", :action => "destroy", :id => "1") 
    end
  end
end
