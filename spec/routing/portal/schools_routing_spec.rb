require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::SchoolsController do
  describe "route generation" do
    it "maps #index" do
      pending "Broken example"
      route_for(:controller => "portal_schools", :action => "index").should == "/portal_schools"
    end

    it "maps #new" do
      pending "Broken example"
      route_for(:controller => "portal_schools", :action => "new").should == "/portal_schools/new"
    end

    it "maps #show" do
      pending "Broken example"
      route_for(:controller => "portal_schools", :action => "show", :id => "1").should == "/portal_schools/1"
    end

    it "maps #edit" do
      pending "Broken example"
      route_for(:controller => "portal_schools", :action => "edit", :id => "1").should == "/portal_schools/1/edit"
    end

    it "maps #create" do
      pending "Broken example"
      route_for(:controller => "portal_schools", :action => "create").should == {:path => "/portal_schools", :method => :post}
    end

    it "maps #update" do
      pending "Broken example"
      route_for(:controller => "portal_schools", :action => "update", :id => "1").should == {:path =>"/portal_schools/1", :method => :put}
    end

    it "maps #destroy" do
      pending "Broken example"
      route_for(:controller => "portal_schools", :action => "destroy", :id => "1").should == {:path =>"/portal_schools/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      pending "Broken example"
      params_from(:get, "/portal_schools").should == {:controller => "portal_schools", :action => "index"}
    end

    it "generates params for #new" do
      pending "Broken example"
      params_from(:get, "/portal_schools/new").should == {:controller => "portal_schools", :action => "new"}
    end

    it "generates params for #create" do
      pending "Broken example"
      params_from(:post, "/portal_schools").should == {:controller => "portal_schools", :action => "create"}
    end

    it "generates params for #show" do
      pending "Broken example"
      params_from(:get, "/portal_schools/1").should == {:controller => "portal_schools", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      pending "Broken example"
      params_from(:get, "/portal_schools/1/edit").should == {:controller => "portal_schools", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      pending "Broken example"
      params_from(:put, "/portal_schools/1").should == {:controller => "portal_schools", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      pending "Broken example"
      params_from(:delete, "/portal_schools/1").should == {:controller => "portal_schools", :action => "destroy", :id => "1"}
    end
  end
end
