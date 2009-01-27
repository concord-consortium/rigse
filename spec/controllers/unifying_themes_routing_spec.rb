require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UnifyingThemesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "unifying_themes", :action => "index").should == "/unifying_themes"
    end
  
    it "should map #new" do
      route_for(:controller => "unifying_themes", :action => "new").should == "/unifying_themes/new"
    end
  
    it "should map #show" do
      route_for(:controller => "unifying_themes", :action => "show", :id => 1).should == "/unifying_themes/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "unifying_themes", :action => "edit", :id => 1).should == "/unifying_themes/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "unifying_themes", :action => "update", :id => 1).should == "/unifying_themes/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "unifying_themes", :action => "destroy", :id => 1).should == "/unifying_themes/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/unifying_themes").should == {:controller => "unifying_themes", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/unifying_themes/new").should == {:controller => "unifying_themes", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/unifying_themes").should == {:controller => "unifying_themes", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/unifying_themes/1").should == {:controller => "unifying_themes", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/unifying_themes/1/edit").should == {:controller => "unifying_themes", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/unifying_themes/1").should == {:controller => "unifying_themes", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/unifying_themes/1").should == {:controller => "unifying_themes", :action => "destroy", :id => "1"}
    end
  end
end
