require 'spec_helper'

describe Dataservice::BundleContentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "dataservice/console_contents" }.should route_to(:controller => "dataservice/console_contents", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "dataservice/console_contents/new" }.should route_to(:controller => "dataservice/console_contents", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "dataservice/console_contents/1" }.should route_to(:controller => "dataservice/console_contents", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "dataservice/console_contents/1/edit" }.should route_to(:controller => "dataservice/console_contents", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "dataservice/console_contents" }.should route_to(:controller => "dataservice/console_contents", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "dataservice/console_contents/1" }.should route_to(:controller => "dataservice/console_contents", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "dataservice/console_contents/1" }.should route_to(:controller => "dataservice/console_contents", :action => "destroy", :id => "1") 
    end
  end
end
