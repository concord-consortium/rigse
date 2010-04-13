require 'spec_helper'

describe  Portal::GradeLevelsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "portal/grade_levels" }.should route_to(:controller => "portal/grade_levels", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "portal/grade_levels/new" }.should route_to(:controller => "portal/grade_levels", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "portal/grade_levels/1" }.should route_to(:controller => "portal/grade_levels", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "portal/grade_levels/1/edit" }.should route_to(:controller => "portal/grade_levels", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "portal/grade_levels" }.should route_to(:controller => "portal/grade_levels", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "portal/grade_levels/1" }.should route_to(:controller => "portal/grade_levels", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "portal/grade_levels/1" }.should route_to(:controller => "portal/grade_levels", :action => "destroy", :id => "1") 
    end
  end
end
