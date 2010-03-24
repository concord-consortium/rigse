require 'spec_helper'

describe  RiGse::AssessmentTargetsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "ri_gse/assessment_targets" }.should route_to(:controller => "ri_gse/assessment_targets", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "ri_gse/assessment_targets/new" }.should route_to(:controller => "ri_gse/assessment_targets", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "ri_gse/assessment_targets/1" }.should route_to(:controller => "ri_gse/assessment_targets", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "ri_gse/assessment_targets/1/edit" }.should route_to(:controller => "ri_gse/assessment_targets", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "ri_gse/assessment_targets" }.should route_to(:controller => "ri_gse/assessment_targets", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "ri_gse/assessment_targets/1" }.should route_to(:controller => "ri_gse/assessment_targets", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "ri_gse/assessment_targets/1" }.should route_to(:controller => "ri_gse/assessment_targets", :action => "destroy", :id => "1") 
    end
  end
end
