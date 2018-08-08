require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::ExpectationsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "ri_gse/expectations" }).to route_to(:controller => "ri_gse/expectations", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "ri_gse/expectations/new" }).to route_to(:controller => "ri_gse/expectations", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "ri_gse/expectations/1" }).to route_to(:controller => "ri_gse/expectations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "ri_gse/expectations/1/edit" }).to route_to(:controller => "ri_gse/expectations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "ri_gse/expectations" }).to route_to(:controller => "ri_gse/expectations", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "ri_gse/expectations/1" }).to route_to(:controller => "ri_gse/expectations", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "ri_gse/expectations/1" }).to route_to(:controller => "ri_gse/expectations", :action => "destroy", :id => "1") 
    end
  end
end
