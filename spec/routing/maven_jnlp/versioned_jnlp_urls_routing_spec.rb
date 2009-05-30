require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MavenJnlp::VersionedJnlpUrlsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "maven_jnlp_versioned_jnlp_urls", :action => "index").should == "/maven_jnlp_versioned_jnlp_urls"
    end
  
    it "maps #new" do
      route_for(:controller => "maven_jnlp_versioned_jnlp_urls", :action => "new").should == "/maven_jnlp_versioned_jnlp_urls/new"
    end
  
    it "maps #show" do
      route_for(:controller => "maven_jnlp_versioned_jnlp_urls", :action => "show", :id => "1").should == "/maven_jnlp_versioned_jnlp_urls/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "maven_jnlp_versioned_jnlp_urls", :action => "edit", :id => "1").should == "/maven_jnlp_versioned_jnlp_urls/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "maven_jnlp_versioned_jnlp_urls", :action => "create").should == {:path => "/maven_jnlp_versioned_jnlp_urls", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "maven_jnlp_versioned_jnlp_urls", :action => "update", :id => "1").should == {:path =>"/maven_jnlp_versioned_jnlp_urls/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "maven_jnlp_versioned_jnlp_urls", :action => "destroy", :id => "1").should == {:path =>"/maven_jnlp_versioned_jnlp_urls/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/maven_jnlp_versioned_jnlp_urls").should == {:controller => "maven_jnlp_versioned_jnlp_urls", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/maven_jnlp_versioned_jnlp_urls/new").should == {:controller => "maven_jnlp_versioned_jnlp_urls", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/maven_jnlp_versioned_jnlp_urls").should == {:controller => "maven_jnlp_versioned_jnlp_urls", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/maven_jnlp_versioned_jnlp_urls/1").should == {:controller => "maven_jnlp_versioned_jnlp_urls", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/maven_jnlp_versioned_jnlp_urls/1/edit").should == {:controller => "maven_jnlp_versioned_jnlp_urls", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/maven_jnlp_versioned_jnlp_urls/1").should == {:controller => "maven_jnlp_versioned_jnlp_urls", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/maven_jnlp_versioned_jnlp_urls/1").should == {:controller => "maven_jnlp_versioned_jnlp_urls", :action => "destroy", :id => "1"}
    end
  end
end
