require 'spec_helper'

describe Admin::TagsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "/admin/tags" }).to route_to(:controller => "admin/tags", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/admin/tags/new" }).to route_to(:controller => "admin/tags", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/admin/tags/1" }).to route_to(:controller => "admin/tags", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/admin/tags/1/edit" }).to route_to(:controller => "admin/tags", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/admin/tags" }).to route_to(:controller => "admin/tags", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/admin/tags/1" }).to route_to(:controller => "admin/tags", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/admin/tags/1" }).to route_to(:controller => "admin/tags", :action => "destroy", :id => "1")
    end
  end
end
