require File.expand_path('../../../spec_helper', __FILE__)

describe  Portal::ExternalUsersController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "portal/external_users" }.should route_to(:controller => "portal/external_users", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "portal/external_users/new" }.should route_to(:controller => "portal/external_users", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "portal/external_users/1" }.should route_to(:controller => "portal/external_users", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "portal/external_users/1/edit" }.should route_to(:controller => "portal/external_users", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "portal/external_users" }.should route_to(:controller => "portal/external_users", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "portal/external_users/1" }.should route_to(:controller => "portal/external_users", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "portal/external_users/1" }.should route_to(:controller => "portal/external_users", :action => "destroy", :id => "1") 
    end
  end
end
