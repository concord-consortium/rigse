require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OtrunkExample::OtmlFilesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "otrunk_example/otml_files", :action => "index").should == "/otrunk_example/otml_files"
    end
  
    it "maps #new" do
      route_for(:controller => "otrunk_example/otml_files", :action => "new").should == "/otrunk_example/otml_files/new"
    end
  
    it "maps #show" do
      route_for(:controller => "otrunk_example/otml_files", :action => "show", :id => "1").should == "/otrunk_example/otml_files/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "otrunk_example/otml_files", :action => "edit", :id => "1").should == "/otrunk_example/otml_files/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "otrunk_example/otml_files", :action => "create").should == {:path => "/otrunk_example/otml_files", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "otrunk_example/otml_files", :action => "update", :id => "1").should == {:path =>"/otrunk_example/otml_files/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "otrunk_example/otml_files", :action => "destroy", :id => "1").should == {:path =>"/otrunk_example/otml_files/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/otrunk_example/otml_files").should == {:controller => "otrunk_example/otml_files", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/otrunk_example/otml_files/new").should == {:controller => "otrunk_example/otml_files", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/otrunk_example/otml_files").should == {:controller => "otrunk_example/otml_files", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/otrunk_example/otml_files/1").should == {:controller => "otrunk_example/otml_files", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/otrunk_example/otml_files/1/edit").should == {:controller => "otrunk_example/otml_files", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/otrunk_example/otml_files/1").should == {:controller => "otrunk_example/otml_files", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/otrunk_example/otml_files/1").should == {:controller => "otrunk_example/otml_files", :action => "destroy", :id => "1"}
    end
  end
end
