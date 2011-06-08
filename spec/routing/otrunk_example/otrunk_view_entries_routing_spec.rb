require File.expand_path('../../../spec_helper', __FILE__)

describe  OtrunkExample::OtrunkViewEntriesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "otrunk_example/otrunk_view_entries" }.should route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "otrunk_example/otrunk_view_entries/new" }.should route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "otrunk_example/otrunk_view_entries/1" }.should route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "otrunk_example/otrunk_view_entries/1/edit" }.should route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "otrunk_example/otrunk_view_entries" }.should route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "otrunk_example/otrunk_view_entries/1" }.should route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "otrunk_example/otrunk_view_entries/1" }.should route_to(:controller => "otrunk_example/otrunk_view_entries", :action => "destroy", :id => "1") 
    end
  end
end
