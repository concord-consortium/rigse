require 'spec_helper'

describe Admin::TagsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/admin_tags" }.should route_to(:controller => "admin_tags", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin_tags/new" }.should route_to(:controller => "admin_tags", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin_tags/1" }.should route_to(:controller => "admin_tags", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin_tags/1/edit" }.should route_to(:controller => "admin_tags", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin_tags" }.should route_to(:controller => "admin_tags", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/admin_tags/1" }.should route_to(:controller => "admin_tags", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin_tags/1" }.should route_to(:controller => "admin_tags", :action => "destroy", :id => "1") 
    end
  end
end
