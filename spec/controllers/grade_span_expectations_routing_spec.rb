require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GradeSpanExpectationsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "grade_span_expectations", :action => "index").should == "/grade_span_expectations"
    end
  
    it "should map #new" do
      route_for(:controller => "grade_span_expectations", :action => "new").should == "/grade_span_expectations/new"
    end
  
    it "should map #show" do
      route_for(:controller => "grade_span_expectations", :action => "show", :id => "1").should == "/grade_span_expectations/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "grade_span_expectations", :action => "edit", :id => "1").should == "/grade_span_expectations/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "grade_span_expectations", :action => "update", :id => "1").should == {:path => "/grade_span_expectations/1", :method => :put}
    end
  
    it "should map #destroy" do
      route_for(:controller => "grade_span_expectations", :action => "destroy", :id => "1").should == {:path => "/grade_span_expectations/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/grade_span_expectations").should == {:controller => "grade_span_expectations", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/grade_span_expectations/new").should == {:controller => "grade_span_expectations", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/grade_span_expectations").should == {:controller => "grade_span_expectations", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/grade_span_expectations/1").should == {:controller => "grade_span_expectations", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/grade_span_expectations/1/edit").should == {:controller => "grade_span_expectations", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/grade_span_expectations/1").should == {:controller => "grade_span_expectations", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/grade_span_expectations/1").should == {:controller => "grade_span_expectations", :action => "destroy", :id => "1"}
    end
  end
end
