require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::DomainsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "ri_gse/domains" }.should route_to(:controller => "ri_gse/domains", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "ri_gse/domains/new" }.should route_to(:controller => "ri_gse/domains", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "ri_gse/domains/1" }.should route_to(:controller => "ri_gse/domains", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "ri_gse/domains/1/edit" }.should route_to(:controller => "ri_gse/domains", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "ri_gse/domains" }.should route_to(:controller => "ri_gse/domains", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "ri_gse/domains/1" }.should route_to(:controller => "ri_gse/domains", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "ri_gse/domains/1" }.should route_to(:controller => "ri_gse/domains", :action => "destroy", :id => "1") 
    end
  end
end
