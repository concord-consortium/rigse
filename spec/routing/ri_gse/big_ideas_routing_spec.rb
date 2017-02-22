require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::BigIdeasController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "ri_gse/big_ideas" }).to route_to(:controller => "ri_gse/big_ideas", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "ri_gse/big_ideas/new" }).to route_to(:controller => "ri_gse/big_ideas", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "ri_gse/big_ideas/1" }).to route_to(:controller => "ri_gse/big_ideas", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "ri_gse/big_ideas/1/edit" }).to route_to(:controller => "ri_gse/big_ideas", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "ri_gse/big_ideas" }).to route_to(:controller => "ri_gse/big_ideas", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "ri_gse/big_ideas/1" }).to route_to(:controller => "ri_gse/big_ideas", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "ri_gse/big_ideas/1" }).to route_to(:controller => "ri_gse/big_ideas", :action => "destroy", :id => "1") 
    end
  end
end
