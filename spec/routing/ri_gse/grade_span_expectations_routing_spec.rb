require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::GradeSpanExpectationsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "ri_gse/grade_span_expectations" }.should route_to(:controller => "ri_gse/grade_span_expectations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "ri_gse/grade_span_expectations/new" }.should route_to(:controller => "ri_gse/grade_span_expectations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "ri_gse/grade_span_expectations/1" }.should route_to(:controller => "ri_gse/grade_span_expectations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "ri_gse/grade_span_expectations/1/edit" }.should route_to(:controller => "ri_gse/grade_span_expectations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "ri_gse/grade_span_expectations" }.should route_to(:controller => "ri_gse/grade_span_expectations", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "ri_gse/grade_span_expectations/1" }.should route_to(:controller => "ri_gse/grade_span_expectations", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "ri_gse/grade_span_expectations/1" }.should route_to(:controller => "ri_gse/grade_span_expectations", :action => "destroy", :id => "1") 
    end
  end
end
