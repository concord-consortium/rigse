require File.expand_path('../../../spec_helper', __FILE__)

describe  OtrunkExample::OtrunkImportsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "otrunk_example/otrunk_imports" }.should route_to(:controller => "otrunk_example/otrunk_imports", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "otrunk_example/otrunk_imports/new" }.should route_to(:controller => "otrunk_example/otrunk_imports", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "otrunk_example/otrunk_imports/1" }.should route_to(:controller => "otrunk_example/otrunk_imports", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "otrunk_example/otrunk_imports/1/edit" }.should route_to(:controller => "otrunk_example/otrunk_imports", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "otrunk_example/otrunk_imports" }.should route_to(:controller => "otrunk_example/otrunk_imports", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "otrunk_example/otrunk_imports/1" }.should route_to(:controller => "otrunk_example/otrunk_imports", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "otrunk_example/otrunk_imports/1" }.should route_to(:controller => "otrunk_example/otrunk_imports", :action => "destroy", :id => "1") 
    end
  end
end
