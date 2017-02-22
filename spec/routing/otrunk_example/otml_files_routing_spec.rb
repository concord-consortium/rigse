require File.expand_path('../../../spec_helper', __FILE__)

describe  OtrunkExample::OtmlFilesController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "otrunk_example/otml_files" }).to route_to(:controller => "otrunk_example/otml_files", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "otrunk_example/otml_files/new" }).to route_to(:controller => "otrunk_example/otml_files", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "otrunk_example/otml_files/1" }).to route_to(:controller => "otrunk_example/otml_files", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "otrunk_example/otml_files/1/edit" }).to route_to(:controller => "otrunk_example/otml_files", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "otrunk_example/otml_files" }).to route_to(:controller => "otrunk_example/otml_files", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "otrunk_example/otml_files/1" }).to route_to(:controller => "otrunk_example/otml_files", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "otrunk_example/otml_files/1" }).to route_to(:controller => "otrunk_example/otml_files", :action => "destroy", :id => "1") 
    end
  end
end
