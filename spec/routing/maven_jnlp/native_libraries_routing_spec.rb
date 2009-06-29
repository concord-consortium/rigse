require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MavenJnlp::NativeLibrariesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "maven_jnlp/native_libraries", :action => "index").should == "/maven_jnlp/native_libraries"
    end
  
    it "maps #new" do
      route_for(:controller => "maven_jnlp/native_libraries", :action => "new").should == "/maven_jnlp/native_libraries/new"
    end
  
    it "maps #show" do
      route_for(:controller => "maven_jnlp/native_libraries", :action => "show", :id => "1").should == "/maven_jnlp/native_libraries/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "maven_jnlp/native_libraries", :action => "edit", :id => "1").should == "/maven_jnlp/native_libraries/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "maven_jnlp/native_libraries", :action => "create").should == {:path => "/maven_jnlp/native_libraries", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "maven_jnlp/native_libraries", :action => "update", :id => "1").should == {:path =>"/maven_jnlp/native_libraries/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "maven_jnlp/native_libraries", :action => "destroy", :id => "1").should == {:path =>"/maven_jnlp/native_libraries/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/maven_jnlp/native_libraries").should == {:controller => "maven_jnlp/native_libraries", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/maven_jnlp/native_libraries/new").should == {:controller => "maven_jnlp/native_libraries", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/maven_jnlp/native_libraries").should == {:controller => "maven_jnlp/native_libraries", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/maven_jnlp/native_libraries/1").should == {:controller => "maven_jnlp/native_libraries", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/maven_jnlp/native_libraries/1/edit").should == {:controller => "maven_jnlp/native_libraries", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/maven_jnlp/native_libraries/1").should == {:controller => "maven_jnlp/native_libraries", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/maven_jnlp/native_libraries/1").should == {:controller => "maven_jnlp/native_libraries", :action => "destroy", :id => "1"}
    end
  end
end
