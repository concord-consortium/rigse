require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::GradesController do
  describe "route generation" do
    it "maps #index" do
      pending "Broken example"
      route_for(:controller => "portal_grades", :action => "index").should == "/portal_grades"
    end

    it "maps #new" do
      pending "Broken example"
      route_for(:controller => "portal_grades", :action => "new").should == "/portal_grades/new"
    end

    it "maps #show" do
      pending "Broken example"
      route_for(:controller => "portal_grades", :action => "show", :id => "1").should == "/portal_grades/1"
    end

    it "maps #edit" do
      pending "Broken example"
      route_for(:controller => "portal_grades", :action => "edit", :id => "1").should == "/portal_grades/1/edit"
    end

    it "maps #create" do
      pending "Broken example"
      route_for(:controller => "portal_grades", :action => "create").should == {:path => "/portal_grades", :method => :post}
    end

    it "maps #update" do
      pending "Broken example"
      route_for(:controller => "portal_grades", :action => "update", :id => "1").should == {:path =>"/portal_grades/1", :method => :put}
    end

    it "maps #destroy" do
      pending "Broken example"
      route_for(:controller => "portal_grades", :action => "destroy", :id => "1").should == {:path =>"/portal_grades/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      pending "Broken example"
      params_from(:get, "/portal_grades").should == {:controller => "portal_grades", :action => "index"}
    end

    it "generates params for #new" do
      pending "Broken example"
      params_from(:get, "/portal_grades/new").should == {:controller => "portal_grades", :action => "new"}
    end

    it "generates params for #create" do
      pending "Broken example"
      params_from(:post, "/portal_grades").should == {:controller => "portal_grades", :action => "create"}
    end

    it "generates params for #show" do
      pending "Broken example"
      params_from(:get, "/portal_grades/1").should == {:controller => "portal_grades", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      pending "Broken example"
      params_from(:get, "/portal_grades/1/edit").should == {:controller => "portal_grades", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      pending "Broken example"
      params_from(:put, "/portal_grades/1").should == {:controller => "portal_grades", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      pending "Broken example"
      params_from(:delete, "/portal_grades/1").should == {:controller => "portal_grades", :action => "destroy", :id => "1"}
    end
  end
end
