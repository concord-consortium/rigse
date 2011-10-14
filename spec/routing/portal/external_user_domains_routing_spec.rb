require File.expand_path('../../../spec_helper', __FILE__)

describe  Portal::ExternalUserDomainsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "portal/external_user_domains" }.should route_to(:controller => "portal/external_user_domains", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "portal/external_user_domains/new" }.should route_to(:controller => "portal/external_user_domains", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "portal/external_user_domains/1" }.should route_to(:controller => "portal/external_user_domains", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "portal/external_user_domains/1/edit" }.should route_to(:controller => "portal/external_user_domains", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "portal/external_user_domains" }.should route_to(:controller => "portal/external_user_domains", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "portal/external_user_domains/1" }.should route_to(:controller => "portal/external_user_domains", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "portal/external_user_domains/1" }.should route_to(:controller => "portal/external_user_domains", :action => "destroy", :id => "1") 
    end
  end
end
