require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ProjectsController do
  describe "route generation" do
    it "maps #index" do
      pending "Broken example"
      route_for(:controller => "admin_projects", :action => "index").should == "/admin_projects"
    end

    it "maps #new" do
      pending "Broken example"
      route_for(:controller => "admin_projects", :action => "new").should == "/admin_projects/new"
    end

    it "maps #show" do
      pending "Broken example"
      route_for(:controller => "admin_projects", :action => "show", :id => "1").should == "/admin_projects/1"
    end

    it "maps #edit" do
      pending "Broken example"
      route_for(:controller => "admin_projects", :action => "edit", :id => "1").should == "/admin_projects/1/edit"
    end

    it "maps #create" do
      pending "Broken example"
      route_for(:controller => "admin_projects", :action => "create").should == {:path => "/admin_projects", :method => :post}
    end

    it "maps #update" do
      pending "Broken example"
      route_for(:controller => "admin_projects", :action => "update", :id => "1").should == {:path =>"/admin_projects/1", :method => :put}
    end

    it "maps #destroy" do
      pending "Broken example"
      route_for(:controller => "admin_projects", :action => "destroy", :id => "1").should == {:path =>"/admin_projects/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      pending "Broken example"
      params_from(:get, "/admin_projects").should == {:controller => "admin_projects", :action => "index"}
    end

    it "generates params for #new" do
      pending "Broken example"
      params_from(:get, "/admin_projects/new").should == {:controller => "admin_projects", :action => "new"}
    end

    it "generates params for #create" do
      pending "Broken example"
      params_from(:post, "/admin_projects").should == {:controller => "admin_projects", :action => "create"}
    end

    it "generates params for #show" do
      pending "Broken example"
      params_from(:get, "/admin_projects/1").should == {:controller => "admin_projects", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      pending "Broken example"
      params_from(:get, "/admin_projects/1/edit").should == {:controller => "admin_projects", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      pending "Broken example"
      params_from(:put, "/admin_projects/1").should == {:controller => "admin_projects", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      pending "Broken example"
      params_from(:delete, "/admin_projects/1").should == {:controller => "admin_projects", :action => "destroy", :id => "1"}
    end
  end
end
