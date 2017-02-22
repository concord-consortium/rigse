require File.expand_path('../../../spec_helper', __FILE__)

describe  Portal::GradeLevelsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "portal/grade_levels" }).to route_to(:controller => "portal/grade_levels", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "portal/grade_levels/new" }).to route_to(:controller => "portal/grade_levels", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "portal/grade_levels/1" }).to route_to(:controller => "portal/grade_levels", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "portal/grade_levels/1/edit" }).to route_to(:controller => "portal/grade_levels", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "portal/grade_levels" }).to route_to(:controller => "portal/grade_levels", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "portal/grade_levels/1" }).to route_to(:controller => "portal/grade_levels", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "portal/grade_levels/1" }).to route_to(:controller => "portal/grade_levels", :action => "destroy", :id => "1") 
    end
  end
end
