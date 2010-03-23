require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe KnowledgeStatementsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "knowledge_statements", :action => "index").should == "/knowledge_statements"
    end
  
    it "should map #new" do
      route_for(:controller => "knowledge_statements", :action => "new").should == "/knowledge_statements/new"
    end
  
    it "should map #show" do
      route_for(:controller => "knowledge_statements", :action => "show", :id => "1").should == "/knowledge_statements/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "knowledge_statements", :action => "edit", :id => "1").should == "/knowledge_statements/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "knowledge_statements", :action => "update", :id => "1").should == {:path => "/knowledge_statements/1", :method => :put}
    end
  
    it "should map #destroy" do
      route_for(:controller => "knowledge_statements", :action => "destroy", :id => "1").should == {:path => "/knowledge_statements/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/knowledge_statements").should == {:controller => "knowledge_statements", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/knowledge_statements/new").should == {:controller => "knowledge_statements", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/knowledge_statements").should == {:controller => "knowledge_statements", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/knowledge_statements/1").should == {:controller => "knowledge_statements", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/knowledge_statements/1/edit").should == {:controller => "knowledge_statements", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/knowledge_statements/1").should == {:controller => "knowledge_statements", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/knowledge_statements/1").should == {:controller => "knowledge_statements", :action => "destroy", :id => "1"}
    end
  end
end
