require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::UnifyingThemesController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "ri_gse/unifying_themes" }).to route_to(:controller => "ri_gse/unifying_themes", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "ri_gse/unifying_themes/new" }).to route_to(:controller => "ri_gse/unifying_themes", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "ri_gse/unifying_themes/1" }).to route_to(:controller => "ri_gse/unifying_themes", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "ri_gse/unifying_themes/1/edit" }).to route_to(:controller => "ri_gse/unifying_themes", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "ri_gse/unifying_themes" }).to route_to(:controller => "ri_gse/unifying_themes", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "ri_gse/unifying_themes/1" }).to route_to(:controller => "ri_gse/unifying_themes", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "ri_gse/unifying_themes/1" }).to route_to(:controller => "ri_gse/unifying_themes", :action => "destroy", :id => "1") 
    end
  end
end
