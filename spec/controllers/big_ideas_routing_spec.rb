require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BigIdeasController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "big_ideas", :action => "index").should == "/big_ideas"
    end
  
    it "should map #new" do
      route_for(:controller => "big_ideas", :action => "new").should == "/big_ideas/new"
    end
  
    it "should map #show" do
      route_for(:controller => "big_ideas", :action => "show", :id => "1").should == "/big_ideas/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "big_ideas", :action => "edit", :id => "1").should == "/big_ideas/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "big_ideas", :action => "update", :id => "1").should == {:path => "/big_ideas/1", :method => :put}
    end
  
    it "should map #destroy" do
      route_for(:controller => "big_ideas", :action => "destroy", :id => "1").should == {:path => "/big_ideas/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/big_ideas").should == {:controller => "big_ideas", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/big_ideas/new").should == {:controller => "big_ideas", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/big_ideas").should == {:controller => "big_ideas", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/big_ideas/1").should == {:controller => "big_ideas", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/big_ideas/1/edit").should == {:controller => "big_ideas", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/big_ideas/1").should == {:controller => "big_ideas", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/big_ideas/1").should == {:controller => "big_ideas", :action => "destroy", :id => "1"}
    end
  end
end
