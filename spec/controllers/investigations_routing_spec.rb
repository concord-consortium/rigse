require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvestigationsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "pages", :action => "index").should == "/pages"
    end
  
    it "should map #new" do
      route_for(:controller => "pages", :action => "new").should == "/pages/new"
    end
  
    it "should map #show" do
      route_for(:controller => "pages", :action => "show", :id => 1).should == "/pages/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "pages", :action => "edit", :id => 1).should == "/pages/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "pages", :action => "update", :id => 1).should == "/pages/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "pages", :action => "destroy", :id => 1).should == "/pages/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/pages").should == {:controller => "pages", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/pages/new").should == {:controller => "pages", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/pages").should == {:controller => "pages", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/pages/1").should == {:controller => "pages", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/pages/1/edit").should == {:controller => "pages", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/pages/1").should == {:controller => "pages", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/pages/1").should == {:controller => "pages", :action => "destroy", :id => "1"}
    end
  end
end
