require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::UnifyingThemesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "ri_gse/unifying_themes" }.should route_to(:controller => "ri_gse/unifying_themes", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "ri_gse/unifying_themes/new" }.should route_to(:controller => "ri_gse/unifying_themes", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "ri_gse/unifying_themes/1" }.should route_to(:controller => "ri_gse/unifying_themes", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "ri_gse/unifying_themes/1/edit" }.should route_to(:controller => "ri_gse/unifying_themes", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "ri_gse/unifying_themes" }.should route_to(:controller => "ri_gse/unifying_themes", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "ri_gse/unifying_themes/1" }.should route_to(:controller => "ri_gse/unifying_themes", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "ri_gse/unifying_themes/1" }.should route_to(:controller => "ri_gse/unifying_themes", :action => "destroy", :id => "1") 
    end
  end
end
