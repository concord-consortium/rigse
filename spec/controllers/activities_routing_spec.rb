require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActivitiesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "investigations", :action => "index").should == "/investigations"
    end
  
    it "should map #new" do
      route_for(:controller => "investigations", :action => "new").should == "/investigations/new"
    end
  
    it "should map #show" do
      route_for(:controller => "investigations", :action => "show", :id => 1).should == "/investigations/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "investigations", :action => "edit", :id => 1).should == "/investigations/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "investigations", :action => "update", :id => 1).should == "/investigations/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "investigations", :action => "destroy", :id => 1).should == "/investigations/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/investigations").should == {:controller => "investigations", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/investigations/new").should == {:controller => "investigations", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/investigations").should == {:controller => "investigations", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/investigations/1").should == {:controller => "investigations", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/investigations/1/edit").should == {:controller => "investigations", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/investigations/1").should == {:controller => "investigations", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/investigations/1").should == {:controller => "investigations", :action => "destroy", :id => "1"}
    end
  end
end
