require File.expand_path('../../../spec_helper', __FILE__)

describe  OtrunkExample::OtrunkViewEntriesController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "otrunk_example/otrunk_view_entries" }).to route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "otrunk_example/otrunk_view_entries/new" }).to route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "otrunk_example/otrunk_view_entries/1" }).to route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "otrunk_example/otrunk_view_entries/1/edit" }).to route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "otrunk_example/otrunk_view_entries" }).to route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "otrunk_example/otrunk_view_entries/1" }).to route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "otrunk_example/otrunk_view_entries/1" }).to route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "destroy", :id => "1") 
    end
  end
end
