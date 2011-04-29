require 'spec_helper'

describe  OtrunkExample::OtmlFilesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "otrunk_example/otml_files" }.should route_to(:controller => "otrunk_example/otml_files", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "otrunk_example/otml_files/new" }.should route_to(:controller => "otrunk_example/otml_files", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "otrunk_example/otml_files/1" }.should route_to(:controller => "otrunk_example/otml_files", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "otrunk_example/otml_files/1/edit" }.should route_to(:controller => "otrunk_example/otml_files", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "otrunk_example/otml_files" }.should route_to(:controller => "otrunk_example/otml_files", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "otrunk_example/otml_files/1" }.should route_to(:controller => "otrunk_example/otml_files", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "otrunk_example/otml_files/1" }.should route_to(:controller => "otrunk_example/otml_files", :action => "destroy", :id => "1") 
    end
  end
end
