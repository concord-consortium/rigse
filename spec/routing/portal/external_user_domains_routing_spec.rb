require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::ExternalUserDomainsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "portal_external_user_domains", :action => "index").should == "/portal_external_user_domains"
    end

    it "maps #new" do
      route_for(:controller => "portal_external_user_domains", :action => "new").should == "/portal_external_user_domains/new"
    end

    it "maps #show" do
      route_for(:controller => "portal_external_user_domains", :action => "show", :id => "1").should == "/portal_external_user_domains/1"
    end

    it "maps #edit" do
      route_for(:controller => "portal_external_user_domains", :action => "edit", :id => "1").should == "/portal_external_user_domains/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "portal_external_user_domains", :action => "create").should == {:path => "/portal_external_user_domains", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "portal_external_user_domains", :action => "update", :id => "1").should == {:path =>"/portal_external_user_domains/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "portal_external_user_domains", :action => "destroy", :id => "1").should == {:path =>"/portal_external_user_domains/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/portal_external_user_domains").should == {:controller => "portal_external_user_domains", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/portal_external_user_domains/new").should == {:controller => "portal_external_user_domains", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/portal_external_user_domains").should == {:controller => "portal_external_user_domains", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/portal_external_user_domains/1").should == {:controller => "portal_external_user_domains", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/portal_external_user_domains/1/edit").should == {:controller => "portal_external_user_domains", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/portal_external_user_domains/1").should == {:controller => "portal_external_user_domains", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/portal_external_user_domains/1").should == {:controller => "portal_external_user_domains", :action => "destroy", :id => "1"}
    end
  end
end
