require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::ExpectationStemsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "ri_gse/expectation_stems" }).to route_to(:controller => "ri_gse/expectation_stems", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "ri_gse/expectation_stems/new" }).to route_to(:controller => "ri_gse/expectation_stems", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "ri_gse/expectation_stems/1" }).to route_to(:controller => "ri_gse/expectation_stems", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "ri_gse/expectation_stems/1/edit" }).to route_to(:controller => "ri_gse/expectation_stems", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "ri_gse/expectation_stems" }).to route_to(:controller => "ri_gse/expectation_stems", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "ri_gse/expectation_stems/1" }).to route_to(:controller => "ri_gse/expectation_stems", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "ri_gse/expectation_stems/1" }).to route_to(:controller => "ri_gse/expectation_stems", :action => "destroy", :id => "1") 
    end
  end
end
