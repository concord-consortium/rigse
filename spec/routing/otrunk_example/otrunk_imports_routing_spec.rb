require File.expand_path('../../../spec_helper', __FILE__)

describe  OtrunkExample::OtrunkImportsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "otrunk_example/otrunk_imports" }).to route_to(:controller => "otrunk_example/otrunk_imports", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "otrunk_example/otrunk_imports/new" }).to route_to(:controller => "otrunk_example/otrunk_imports", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "otrunk_example/otrunk_imports/1" }).to route_to(:controller => "otrunk_example/otrunk_imports", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "otrunk_example/otrunk_imports/1/edit" }).to route_to(:controller => "otrunk_example/otrunk_imports", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "otrunk_example/otrunk_imports" }).to route_to(:controller => "otrunk_example/otrunk_imports", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "otrunk_example/otrunk_imports/1" }).to route_to(:controller => "otrunk_example/otrunk_imports", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "otrunk_example/otrunk_imports/1" }).to route_to(:controller => "otrunk_example/otrunk_imports", :action => "destroy", :id => "1") 
    end
  end
end
