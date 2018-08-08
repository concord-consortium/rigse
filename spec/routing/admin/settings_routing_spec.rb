require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::SettingsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "admin/settings" }).to route_to(:controller => "admin/settings", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/settings/new" }).to route_to(:controller => "admin/settings", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/settings/1" }).to route_to(:controller => "admin/settings", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/settings/1/edit" }).to route_to(:controller => "admin/settings", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/settings" }).to route_to(:controller => "admin/settings", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/settings/1" }).to route_to(:controller => "admin/settings", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/settings/1" }).to route_to(:controller => "admin/settings", :action => "destroy", :id => "1") 
    end
  end
end
