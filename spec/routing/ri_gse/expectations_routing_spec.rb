require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::ExpectationsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "ri_gse/expectations" }.should route_to(:controller => "ri_gse/expectations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "ri_gse/expectations/new" }.should route_to(:controller => "ri_gse/expectations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "ri_gse/expectations/1" }.should route_to(:controller => "ri_gse/expectations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "ri_gse/expectations/1/edit" }.should route_to(:controller => "ri_gse/expectations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "ri_gse/expectations" }.should route_to(:controller => "ri_gse/expectations", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "ri_gse/expectations/1" }.should route_to(:controller => "ri_gse/expectations", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "ri_gse/expectations/1" }.should route_to(:controller => "ri_gse/expectations", :action => "destroy", :id => "1") 
    end
  end
end
