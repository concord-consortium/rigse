require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Dataservice::BundleLoggersController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "dataservice_bundle_loggers", :action => "index").should == "/dataservice_bundle_loggers"
    end

    it "maps #new" do
      route_for(:controller => "dataservice_bundle_loggers", :action => "new").should == "/dataservice_bundle_loggers/new"
    end

    it "maps #show" do
      route_for(:controller => "dataservice_bundle_loggers", :action => "show", :id => "1").should == "/dataservice_bundle_loggers/1"
    end

    it "maps #edit" do
      route_for(:controller => "dataservice_bundle_loggers", :action => "edit", :id => "1").should == "/dataservice_bundle_loggers/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "dataservice_bundle_loggers", :action => "create").should == {:path => "/dataservice_bundle_loggers", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "dataservice_bundle_loggers", :action => "update", :id => "1").should == {:path =>"/dataservice_bundle_loggers/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "dataservice_bundle_loggers", :action => "destroy", :id => "1").should == {:path =>"/dataservice_bundle_loggers/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/dataservice_bundle_loggers").should == {:controller => "dataservice_bundle_loggers", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/dataservice_bundle_loggers/new").should == {:controller => "dataservice_bundle_loggers", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/dataservice_bundle_loggers").should == {:controller => "dataservice_bundle_loggers", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/dataservice_bundle_loggers/1").should == {:controller => "dataservice_bundle_loggers", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/dataservice_bundle_loggers/1/edit").should == {:controller => "dataservice_bundle_loggers", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/dataservice_bundle_loggers/1").should == {:controller => "dataservice_bundle_loggers", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/dataservice_bundle_loggers/1").should == {:controller => "dataservice_bundle_loggers", :action => "destroy", :id => "1"}
    end
  end
end
