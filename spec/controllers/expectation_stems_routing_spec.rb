require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExpectationStemsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "expectation_stems", :action => "index").should == "/expectation_stems"
    end
  
    it "should map #new" do
      route_for(:controller => "expectation_stems", :action => "new").should == "/expectation_stems/new"
    end
  
    it "should map #show" do
      route_for(:controller => "expectation_stems", :action => "show", :id => 1).should == "/expectation_stems/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "expectation_stems", :action => "edit", :id => 1).should == "/expectation_stems/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "expectation_stems", :action => "update", :id => 1).should == "/expectation_stems/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "expectation_stems", :action => "destroy", :id => 1).should == "/expectation_stems/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/expectation_stems").should == {:controller => "expectation_stems", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/expectation_stems/new").should == {:controller => "expectation_stems", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/expectation_stems").should == {:controller => "expectation_stems", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/expectation_stems/1").should == {:controller => "expectation_stems", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/expectation_stems/1/edit").should == {:controller => "expectation_stems", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/expectation_stems/1").should == {:controller => "expectation_stems", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/expectation_stems/1").should == {:controller => "expectation_stems", :action => "destroy", :id => "1"}
    end
  end
end
