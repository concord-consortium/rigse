require File.expand_path('../../../spec_helper', __FILE__)

describe  Portal::GradesController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "portal/grades" }).to route_to(:controller => "portal/grades", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "portal/grades/new" }).to route_to(:controller => "portal/grades", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "portal/grades/1" }).to route_to(:controller => "portal/grades", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "portal/grades/1/edit" }).to route_to(:controller => "portal/grades", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "portal/grades" }).to route_to(:controller => "portal/grades", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "portal/grades/1" }).to route_to(:controller => "portal/grades", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "portal/grades/1" }).to route_to(:controller => "portal/grades", :action => "destroy", :id => "1") 
    end
  end
end
