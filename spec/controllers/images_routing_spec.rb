require File.expand_path('../../spec_helper', __FILE__)
describe ImagesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "images", :action => "index").should == "/images"
    end
  
    it "should map #new" do
      route_for(:controller => "images", :action => "new").should == "/images/new"
    end
  
    it "should map #show" do
      route_for(:controller => "images", :action => "show", :id => "1").should == "/images/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "images", :action => "edit", :id => "1").should == "/images/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "images", :action => "update", :id => "1").should == {:path => "/images/1", :method => :put}
    end
  
    it "should map #destroy" do
      route_for(:controller => "images", :action => "destroy", :id => "1").should == {:path => "/images/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/images").should == {:controller => "images", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/images/new").should == {:controller => "images", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/images").should == {:controller => "images", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/images/1").should == {:controller => "images", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/images/1/edit").should == {:controller => "images", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/images/1").should == {:controller => "images", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/images/1").should == {:controller => "images", :action => "destroy", :id => "1"}
    end
  end
end
