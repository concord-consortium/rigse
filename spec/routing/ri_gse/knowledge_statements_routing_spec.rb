require File.expand_path('../../../spec_helper', __FILE__)

describe  RiGse::KnowledgeStatementsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "ri_gse/knowledge_statements" }.should route_to(:controller => "ri_gse/knowledge_statements", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "ri_gse/knowledge_statements/new" }.should route_to(:controller => "ri_gse/knowledge_statements", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "ri_gse/knowledge_statements/1" }.should route_to(:controller => "ri_gse/knowledge_statements", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "ri_gse/knowledge_statements/1/edit" }.should route_to(:controller => "ri_gse/knowledge_statements", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "ri_gse/knowledge_statements" }.should route_to(:controller => "ri_gse/knowledge_statements", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "ri_gse/knowledge_statements/1" }.should route_to(:controller => "ri_gse/knowledge_statements", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "ri_gse/knowledge_statements/1" }.should route_to(:controller => "ri_gse/knowledge_statements", :action => "destroy", :id => "1") 
    end
  end
end
