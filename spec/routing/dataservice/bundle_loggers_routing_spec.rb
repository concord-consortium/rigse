require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Dataservice::BundleLoggersController do
  describe "route generation" do
    it "maps #index" do
      pending "Broken example"
      route_for(:controller => "dataservice_bundle_loggers", :action => "index").should == "/dataservice_bundle_loggers"
    end

    it "maps #new" do
      pending "Broken example"
      route_for(:controller => "dataservice_bundle_loggers", :action => "new").should == "/dataservice_bundle_loggers/new"
    end

    it "maps #show" do
      pending "Broken example"
      route_for(:controller => "dataservice_bundle_loggers", :action => "show", :id => "1").should == "/dataservice_bundle_loggers/1"
    end

    it "maps #edit" do
      pending "Broken example"
      route_for(:controller => "dataservice_bundle_loggers", :action => "edit", :id => "1").should == "/dataservice_bundle_loggers/1/edit"
    end

    it "maps #create" do
      pending "Broken example"
      route_for(:controller => "dataservice_bundle_loggers", :action => "create").should == {:path => "/dataservice_bundle_loggers", :method => :post}
    end

    it "maps #update" do
      pending "Broken example"
      route_for(:controller => "dataservice_bundle_loggers", :action => "update", :id => "1").should == {:path =>"/dataservice_bundle_loggers/1", :method => :put}
    end

    it "maps #destroy" do
      pending "Broken example"
      route_for(:controller => "dataservice_bundle_loggers", :action => "destroy", :id => "1").should == {:path =>"/dataservice_bundle_loggers/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      pending "Broken example"
      params_from(:get, "/dataservice_bundle_loggers").should == {:controller => "dataservice_bundle_loggers", :action => "index"}
    end

    it "generates params for #new" do
      pending "Broken example"
      params_from(:get, "/dataservice_bundle_loggers/new").should == {:controller => "dataservice_bundle_loggers", :action => "new"}
    end

    it "generates params for #create" do
      pending "Broken example"
      params_from(:post, "/dataservice_bundle_loggers").should == {:controller => "dataservice_bundle_loggers", :action => "create"}
    end

    it "generates params for #show" do
      pending "Broken example"
      params_from(:get, "/dataservice_bundle_loggers/1").should == {:controller => "dataservice_bundle_loggers", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      pending "Broken example"
      params_from(:get, "/dataservice_bundle_loggers/1/edit").should == {:controller => "dataservice_bundle_loggers", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      pending "Broken example"
      params_from(:put, "/dataservice_bundle_loggers/1").should == {:controller => "dataservice_bundle_loggers", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      pending "Broken example"
      params_from(:delete, "/dataservice_bundle_loggers/1").should == {:controller => "dataservice_bundle_loggers", :action => "destroy", :id => "1"}
    end
  end
end
