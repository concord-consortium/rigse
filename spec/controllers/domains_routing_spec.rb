require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DomainsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "domains", :action => "index").should == "/domains"
    end
  
    it "should map #new" do
      route_for(:controller => "domains", :action => "new").should == "/domains/new"
    end
  
    it "should map #show" do
      route_for(:controller => "domains", :action => "show", :id => 1).should == "/domains/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "domains", :action => "edit", :id => 1).should == "/domains/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "domains", :action => "update", :id => 1).should == "/domains/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "domains", :action => "destroy", :id => 1).should == "/domains/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/domains").should == {:controller => "domains", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/domains/new").should == {:controller => "domains", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/domains").should == {:controller => "domains", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/domains/1").should == {:controller => "domains", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/domains/1/edit").should == {:controller => "domains", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/domains/1").should == {:controller => "domains", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/domains/1").should == {:controller => "domains", :action => "destroy", :id => "1"}
    end
  end
end
