require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MavenJnlp::PropertiesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "maven_jnlp/properties", :action => "index").should == "/maven_jnlp/properties"
    end
  
    it "maps #new" do
      route_for(:controller => "maven_jnlp/properties", :action => "new").should == "/maven_jnlp/properties/new"
    end
  
    it "maps #show" do
      route_for(:controller => "maven_jnlp/properties", :action => "show", :id => "1").should == "/maven_jnlp/properties/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "maven_jnlp/properties", :action => "edit", :id => "1").should == "/maven_jnlp/properties/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "maven_jnlp/properties", :action => "create").should == {:path => "/maven_jnlp/properties", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "maven_jnlp/properties", :action => "update", :id => "1").should == {:path =>"/maven_jnlp/properties/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "maven_jnlp/properties", :action => "destroy", :id => "1").should == {:path =>"/maven_jnlp/properties/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/maven_jnlp/properties").should == {:controller => "maven_jnlp/properties", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/maven_jnlp/properties/new").should == {:controller => "maven_jnlp/properties", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/maven_jnlp/properties").should == {:controller => "maven_jnlp/properties", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/maven_jnlp/properties/1").should == {:controller => "maven_jnlp/properties", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/maven_jnlp/properties/1/edit").should == {:controller => "maven_jnlp/properties", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/maven_jnlp/properties/1").should == {:controller => "maven_jnlp/properties", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/maven_jnlp/properties/1").should == {:controller => "maven_jnlp/properties", :action => "destroy", :id => "1"}
    end
  end
end
