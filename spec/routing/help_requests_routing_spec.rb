require 'spec_helper'

describe HelpRequestsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/help_requests" }.should route_to(:controller => "help_requests", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/help_requests/new" }.should route_to(:controller => "help_requests", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/help_requests/1" }.should route_to(:controller => "help_requests", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/help_requests/1/edit" }.should route_to(:controller => "help_requests", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/help_requests" }.should route_to(:controller => "help_requests", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/help_requests/1" }.should route_to(:controller => "help_requests", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/help_requests/1" }.should route_to(:controller => "help_requests", :action => "destroy", :id => "1") 
    end
  end
end
