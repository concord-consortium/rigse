require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::SettingsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "admin/settings" }.should route_to(:controller => "admin/settings", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "admin/settings/new" }.should route_to(:controller => "admin/settings", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "admin/settings/1" }.should route_to(:controller => "admin/settings", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "admin/settings/1/edit" }.should route_to(:controller => "admin/settings", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "admin/settings" }.should route_to(:controller => "admin/settings", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "admin/settings/1" }.should route_to(:controller => "admin/settings", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "admin/settings/1" }.should route_to(:controller => "admin/settings", :action => "destroy", :id => "1") 
    end
  end
end
