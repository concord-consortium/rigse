require 'spec_helper'

describe  RiGse::ExpectationStemsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "ri_gse/expectation_stems" }.should route_to(:controller => "ri_gse/expectation_stems", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "ri_gse/expectation_stems/new" }.should route_to(:controller => "ri_gse/expectation_stems", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "ri_gse/expectation_stems/1" }.should route_to(:controller => "ri_gse/expectation_stems", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "ri_gse/expectation_stems/1/edit" }.should route_to(:controller => "ri_gse/expectation_stems", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "ri_gse/expectation_stems" }.should route_to(:controller => "ri_gse/expectation_stems", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "ri_gse/expectation_stems/1" }.should route_to(:controller => "ri_gse/expectation_stems", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "ri_gse/expectation_stems/1" }.should route_to(:controller => "ri_gse/expectation_stems", :action => "destroy", :id => "1") 
    end
  end
end
