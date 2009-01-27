require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AssessmentTargetsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "assessment_targets", :action => "index").should == "/assessment_targets"
    end
  
    it "should map #new" do
      route_for(:controller => "assessment_targets", :action => "new").should == "/assessment_targets/new"
    end
  
    it "should map #show" do
      route_for(:controller => "assessment_targets", :action => "show", :id => 1).should == "/assessment_targets/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "assessment_targets", :action => "edit", :id => 1).should == "/assessment_targets/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "assessment_targets", :action => "update", :id => 1).should == "/assessment_targets/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "assessment_targets", :action => "destroy", :id => 1).should == "/assessment_targets/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/assessment_targets").should == {:controller => "assessment_targets", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/assessment_targets/new").should == {:controller => "assessment_targets", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/assessment_targets").should == {:controller => "assessment_targets", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/assessment_targets/1").should == {:controller => "assessment_targets", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/assessment_targets/1/edit").should == {:controller => "assessment_targets", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/assessment_targets/1").should == {:controller => "assessment_targets", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/assessment_targets/1").should == {:controller => "assessment_targets", :action => "destroy", :id => "1"}
    end
  end
end
