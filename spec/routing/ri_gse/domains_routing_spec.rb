require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::DomainsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "ri_gse/domains" }).to route_to(:controller => "ri_gse/domains", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "ri_gse/domains/new" }).to route_to(:controller => "ri_gse/domains", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "ri_gse/domains/1" }).to route_to(:controller => "ri_gse/domains", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "ri_gse/domains/1/edit" }).to route_to(:controller => "ri_gse/domains", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "ri_gse/domains" }).to route_to(:controller => "ri_gse/domains", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "ri_gse/domains/1" }).to route_to(:controller => "ri_gse/domains", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "ri_gse/domains/1" }).to route_to(:controller => "ri_gse/domains", :action => "destroy", :id => "1") 
    end
  end
end
