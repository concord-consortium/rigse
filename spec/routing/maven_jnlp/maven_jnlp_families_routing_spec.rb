require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MavenJnlp::MavenJnlpFamiliesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "maven_jnlp/maven_jnlp/families", :action => "index").should == "/maven_jnlp/maven_jnlp/families"
    end
  
    it "maps #new" do
      route_for(:controller => "maven_jnlp/maven_jnlp/families", :action => "new").should == "/maven_jnlp/maven_jnlp/families/new"
    end
  
    it "maps #show" do
      route_for(:controller => "maven_jnlp/maven_jnlp/families", :action => "show", :id => "1").should == "/maven_jnlp/maven_jnlp/families/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "maven_jnlp/maven_jnlp/families", :action => "edit", :id => "1").should == "/maven_jnlp/maven_jnlp/families/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "maven_jnlp/maven_jnlp/families", :action => "create").should == {:path => "/maven_jnlp/maven_jnlp/families", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "maven_jnlp/maven_jnlp/families", :action => "update", :id => "1").should == {:path =>"/maven_jnlp/maven_jnlp/families/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "maven_jnlp/maven_jnlp/families", :action => "destroy", :id => "1").should == {:path =>"/maven_jnlp/maven_jnlp/families/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/maven_jnlp/maven_jnlp/families").should == {:controller => "maven_jnlp/maven_jnlp/families", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/maven_jnlp/maven_jnlp/families/new").should == {:controller => "maven_jnlp/maven_jnlp/families", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/maven_jnlp/maven_jnlp/families").should == {:controller => "maven_jnlp/maven_jnlp/families", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/maven_jnlp/maven_jnlp/families/1").should == {:controller => "maven_jnlp/maven_jnlp/families", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/maven_jnlp/maven_jnlp/families/1/edit").should == {:controller => "maven_jnlp/maven_jnlp/families", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/maven_jnlp/maven_jnlp/families/1").should == {:controller => "maven_jnlp/maven_jnlp/families", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/maven_jnlp/maven_jnlp/families/1").should == {:controller => "maven_jnlp/maven_jnlp/families", :action => "destroy", :id => "1"}
    end
  end
end
